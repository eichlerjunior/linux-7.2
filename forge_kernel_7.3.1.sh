#!/bin/bash
set -e

# Diretórios de trabalho e parâmetros de otimização
WORK_DIR="${HOME}/kernel-dev"
KERNEL_VERSION="7.3.1"
KERNEL_DIR="${WORK_DIR}/linux-${KERNEL_VERSION}"
TARBALL="linux-${KERNEL_VERSION}.tar.xz"
URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/${TARBALL}"
CONFIG_FILE="${KERNEL_DIR}/.config"
BACKUP_FILE="${KERNEL_DIR}/.config.backup.original"
THREADS="8"

echo "========================================================================="
echo "FORJA AUTOMATIZADA DE KERNEL MONOLÍTICO ${KERNEL_VERSION} (LLVM + 8 THREADS)"
echo "========================================================================="
echo ""

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 1. Download automático do código-fonte se não existir
if [ ! -d "$KERNEL_DIR" ]; then
    if [ ! -f "$TARBALL" ]; then
        echo "[*] Baixando o código-fonte do Kernel ${KERNEL_VERSION} do site oficial..."
        wget -c "$URL"
    else
        echo "[*] Arquivo tarball já existente. Pulando download..."
    fi

    echo "[*] Descompactando o código-fonte..."
    tar -xf "$TARBALL"
else
    echo "[*] Diretório do kernel ${KERNEL_VERSION} já descompactado."
fi

cd "$KERNEL_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "[*] Gerando configuração padrão baseada no kernel atual do sistema..."
    cp /boot/config-$(uname -r) "$CONFIG_FILE"
    make LLVM=1 olddefconfig
fi

echo "[1/7] Criando backup da configuração original..."
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "      Backup salvo em: $BACKUP_FILE"
echo ""

echo "[2/7] Expurgando suporte AMD/ATI legado..."
sed -i 's/^CONFIG_CPU_SUP_AMD=y/# CONFIG_CPU_SUP_AMD is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_X86_MCE_AMD=y/# CONFIG_X86_MCE_AMD is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_DRM_AMDGPU=y/# CONFIG_DRM_AMDGPU is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_DRM_RADEON=y/# CONFIG_DRM_RADEON is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_HSA_AMD=y/# CONFIG_HSA_AMD is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_AMD_NB=y/# CONFIG_AMD_NB is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_K10=y/# CONFIG_K10 is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_PARPORT=y/# CONFIG_PARPORT is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_GAMEPORT=y/# CONFIG_GAMEPORT is not set/' "$CONFIG_FILE"
echo "      OK"
echo ""

echo "[3/7] Injetando drivers críticos em modo MONOLÍTICO (=y)..."
cat >> "$CONFIG_FILE" << 'EOF'

# === DRIVERS CRÍTICOS THINKPAD P52 (MONOLÍTICO) ===
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_SND=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_E1000E=y
CONFIG_IWLWIFI=y
CONFIG_IWLMVM=y
CONFIG_BT=y
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_INTEL=y
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_SATA_AHCI=y
CONFIG_FIRMWARE_LOADER=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_POWERCAP=y
CONFIG_INTEL_RAPL=y
CONFIG_ACPI_THINKPAD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_DRM_I915=y
CONFIG_DRM=y
CONFIG_FB=y
CONFIG_MODULES=y
CONFIG_MODVERSIONS=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_TCG_TPM=y
CONFIG_INTEL_IOMMU=y
CONFIG_EXT4_FS=y
CONFIG_FUSE_FS=y
CONFIG_NTFS3_FS=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
CONFIG_PREEMPT_VOLUNTARY=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_HWMON=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_LEDS_CLASS=y
CONFIG_WATCHDOG=y
CONFIG_RTC_CLASS=y
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_SHA256=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_BPF_SYSCALL=y
CONFIG_PERF_EVENTS=y
EOF
echo "      OK"
echo ""

echo "[4/7] Otimizando sistemas de arquivos..."
sed -i 's/^CONFIG_BTRFS_FS=y/# CONFIG_BTRFS_FS is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_XFS_FS=y/# CONFIG_XFS_FS is not set/' "$CONFIG_FILE"
echo "      OK"
echo ""

echo "[5/7] Validando integridade da configuração..."
echo ""
echo "=== DRIVERS CRÍTICOS MONOLÍTICOS ==="
for opt in CONFIG_MOUSE_PS2_ELANTECH CONFIG_SND_HDA_INTEL CONFIG_IWLWIFI CONFIG_NVME_CORE CONFIG_SATA_AHCI CONFIG_E1000E CONFIG_DRM_I915; do
    grep "^$opt=" "$CONFIG_FILE" && echo "  ✓ $opt" || echo "  ⚠ $opt NÃO ENCONTRADO"
done
echo ""
echo "=== SUPORTE AMD (expurgado) ==="
AMD_ATIVO=$(grep -E "^CONFIG_CPU_SUP_AMD=|^CONFIG_DRM_AMDGPU=" "$CONFIG_FILE" | grep "=y" || true)
if [ -z "$AMD_ATIVO" ]; then
    echo "  ✓ AMD removido com sucesso"
else
    echo "  ⚠ Atenção, AMD ainda ativo:"
    echo "$AMD_ATIVO"
fi
echo ""

echo "[6/7] Atualizando dependências de configuração..."
make LLVM=1 olddefconfig

echo "[7/7] INICIANDO COMPILAÇÃO PURA VIA LLVM (Estritamente ${THREADS} Threads)..."
make LLVM=1 -j${THREADS}

echo ""
echo "========================================================================="
echo "COMPILAÇÃO CONCLUÍDA COM SUCESSO!"
echo "Para instalar os módulos e o kernel monolítico no sistema, execute:"
echo "cd ${KERNEL_DIR}"
echo "sudo make modules_install"
echo "sudo make install"
echo "========================================================================="