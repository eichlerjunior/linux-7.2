#!/bin/bash
# ============================================================
# Script de compilacao do kernel 7.2.4
# ============================================================

set -e
trap 'echo "ERRO na linha $LINENO. Veja o log: $LOG_FILE"' ERR

KERNEL_VERSION="7.2.4"
KERNEL_DIR="/home/eichlerjr/kernel-dev/linux-${KERNEL_VERSION}"
LOG_FILE="build-${KERNEL_VERSION}-$(date +%Y%m%d-%H%M%S).log"
JOBS=$(nproc)

check_deps() {
    local bins=("gcc" "make" "flex" "bison" "openssl" "bc" "pahole" "zstd" "rsync" "gawk")
    local headers=("/usr/include/elf.h" "/usr/include/gelf.h" "/usr/include/dwarf.h")
    local missing=()
    for bin in "${bins[@]}"; do
        if ! command -v $bin &>/dev/null; then
            missing+=("$bin")
        fi
    done
    for hdr in "${headers[@]}"; do
        if [ ! -f "$hdr" ]; then
            missing+=("$(basename $hdr)")
        fi
    done
    if [ ${#missing[@]} -ne 0 ]; then
        echo "Dependencias faltando: ${missing[*]}"
        echo "   Execute: sudo apt install build-essential libncurses-dev bison flex libssl-dev bc dwarves zstd rsync libelf-dev libdw-dev libdwarf-dev gawk"
        exit 1
    fi
}

echo "COMPILACAO DO KERNEL ${KERNEL_VERSION}" | tee "$LOG_FILE"
echo "Inicio: $(date)" | tee -a "$LOG_FILE"
echo "Hardware: $(uname -m), ${JOBS} nucleos, $(free -h | grep Mem | awk '{print $2}') RAM" | tee -a "$LOG_FILE"

check_deps

cd "$KERNEL_DIR" || { echo "Diretorio nao encontrado!"; exit 1; }

echo "[1/6] Limpando compilacoes anteriores..." | tee -a "$LOG_FILE"
make clean
make mrproper

echo "[2/6] Usando configuracao do kernel atual..." | tee -a "$LOG_FILE"
cp /boot/config-$(uname -r) .config
cp .config .config.bak

echo "[3/6] Reduzindo drivers (localmodconfig)..." | tee -a "$LOG_FILE"
yes "" | make localmodconfig > /dev/null 2>&1
yes "" | make olddefconfig > /dev/null 2>&1

echo "[4/6] Aplicando otimizacoes (hardware especifico)..." | tee -a "$LOG_FILE"
scripts/config \
    --disable CONFIG_BLK_DEV_FD \
    --disable CONFIG_PARPORT \
    --disable CONFIG_ISA \
    --disable CONFIG_MCA \
    --disable CONFIG_EISA \
    --disable CONFIG_ATM \
    --disable CONFIG_IPX \
    --disable CONFIG_APPLETALK \
    --disable CONFIG_WAN \
    --disable CONFIG_ARCNET \
    --disable CONFIG_FDDI \
    --disable CONFIG_HIPPI \
    --disable CONFIG_PLIP \
    --disable CONFIG_SLIP \
    --disable CONFIG_BTRFS_FS \
    --disable CONFIG_XFS_FS \
    --disable CONFIG_REISERFS_FS \
    --disable CONFIG_JFS_FS \
    --disable CONFIG_OCFS2_FS \
    --disable CONFIG_GFS2_FS \
    --disable CONFIG_AFS_FS \
    --disable CONFIG_NILFS2_FS \
    --disable CONFIG_F2FS_FS \
    --disable CONFIG_DEBUG_KERNEL \
    --disable CONFIG_DEBUG_FS \
    --disable CONFIG_DEBUG_MISC \
    --disable CONFIG_KGDB \
    --disable CONFIG_UBSAN \
    --disable CONFIG_KASAN \
    --disable CONFIG_KCOV \
    --disable CONFIG_FTRACE \
    --disable CONFIG_FUNCTION_TRACER \
    --disable CONFIG_DYNAMIC_FTRACE \
    --disable CONFIG_JOYSTICK \
    --disable CONFIG_TABLET_USB \
    --disable CONFIG_TOUCHSCREEN \
    --disable CONFIG_KVM \
    --disable CONFIG_VIRTUALIZATION \
    --disable CONFIG_XEN \
    --disable CONFIG_SND_DRIVERS \
    --disable CONFIG_SND_ISA \
    --disable CONFIG_SND_PCI \
    --disable CONFIG_SND_USB \
    --enable CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE \
    --disable CONFIG_CC_OPTIMIZE_FOR_SIZE \
    --set-val CONFIG_HZ 1000 \
    --enable CONFIG_SCHED_AUTOGROUP \
    --disable CONFIG_MODULE_SIG \
    --disable CONFIG_MODULE_SIG_FORCE \
    --disable CONFIG_SYSTEM_REVOCATION_LIST \
    --enable CONFIG_NVME_MULTIPATH \
    --enable CONFIG_DRM_NOUVEAU \
    --enable CONFIG_FRAMEBUFFER_CONSOLE \
    --disable CONFIG_WERROR

# Cria certificados dummy
mkdir -p debian
touch debian/canonical-certs.pem
touch debian/canonical-revoked-certs.pem

echo "[5/6] Validando configuracao..." | tee -a "$LOG_FILE"
yes "" | make olddefconfig > /dev/null 2>&1

echo "[6/6] Compilando kernel (pode levar de 30min a 1h)..." | tee -a "$LOG_FILE"
make -j$JOBS 2>&1 | tee -a "$LOG_FILE"
make modules -j$JOBS 2>&1 | tee -a "$LOG_FILE"

# Geracao de pacotes .deb
echo "Gerando pacotes .deb..." | tee -a "$LOG_FILE"
make bindeb-pkg -j$JOBS 2>&1 | tee -a "$LOG_FILE"

echo "============================================" | tee -a "$LOG_FILE"
echo "KERNEL ${KERNEL_VERSION} COMPILADO E INSTALADO!" | tee -a "$LOG_FILE"
echo "Pacotes .deb gerados em: /home/eichlerjr/kernel-dev/" | tee -a "$LOG_FILE"
echo "Para instalar, execute:" | tee -a "$LOG_FILE"
echo "sudo dpkg -i /home/eichlerjr/kernel-dev/linux-*.deb" | tee -a "$LOG_FILE"
echo "Depois reinicie e selecione o novo kernel no GRUB." | tee -a "$LOG_FILE"
date | tee -a "$LOG_FILE"
