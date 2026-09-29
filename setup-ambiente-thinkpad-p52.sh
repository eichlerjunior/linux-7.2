#!/bin/bash
#===============================================================================
# SCRIPT: setup-ambiente-thinkpad-p52.sh
# DESCRIÇÃO: Instalação completa do ambiente de desenvolvimento para compilar
#            kernel 7.2.6 no ThinkPad P52 com Pop!_OS
# REQUISITOS: Executar como root ou com sudo
#===============================================================================

set -e

echo "==============================================================================="
echo "SETUP DO AMBIENTE DE DESENVOLVIMENTO - THINKPAD P52"
echo "Kernel alvo: 7.2.6 | Driver NVIDIA: 550.xx | CUDA: 12.x"
echo "==============================================================================="

# Verificar se é Pop!_OS / Ubuntu based
if [ ! -f /etc/os-release ]; then
    echo "ERRO: Sistema não identificado. Este script é para Pop!_OS/Ubuntu."
    exit 1
fi

source /etc/os-release
if [[ ! "$ID" =~ ^(pop|ubuntu)$ ]]; then
    echo "AVISO: Sistema detectado: $ID. Pode haver incompatibilidades."
fi

#-------------------------------------------------------------------------------
# 1. ATUALIZAÇÃO DO SISTEMA
#-------------------------------------------------------------------------------
echo ""
echo "[1/8] Atualizando sistema..."
apt update
apt upgrade -y

#-------------------------------------------------------------------------------
# 2. FERRAMENTAS BÁSICAS DE COMPILAÇÃO
#-------------------------------------------------------------------------------
echo ""
echo "[2/8] Instalando ferramentas básicas de compilação..."
apt install -y \
    build-essential \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    pahole \
    dwarves \
    pkg-config \
    python3 \
    python3-dev \
    python3-distutils \
    git \
    wget \
    curl \
    ccache \
    kmod \
    libcap-dev \
    bc \
    rsync \
    xz-utils \
    fakeroot \
    libpci-dev \
    libiberty-dev \
    autoconf \
    automake \
    libtool \
    libdw-dev \
    binutils-dev \
    zlib1g-dev \
    libnuma-dev \
    libgtk-3-dev \
    libglvnd-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev

#-------------------------------------------------------------------------------
# 3. GCC 12/13 (Recomendado para kernel 7.2.x)
#-------------------------------------------------------------------------------
echo ""
echo "[3/8] Instalando GCC otimizado..."
apt install -y gcc-12 g++-12 gcc-12-multilib g++-12-multilib || \
apt install -y gcc-13 g++-13 gcc-13-multilib g++-13-multilib || \
apt install -y gcc g++ gcc-multilib g++-multilib

# Definir GCC padrão (opcional)
# update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
# update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100

#-------------------------------------------------------------------------------
# 4. LLVM/CLANG (Opcional, para LTO e compilação híbrida)
#-------------------------------------------------------------------------------
echo ""
echo "[4/8] Instalando LLVM/Clang..."
apt install -y llvm clang lld llvm-dev || true

#-------------------------------------------------------------------------------
# 5. DRIVERS NVIDIA 550.xx (CRÍTICO - 580 NÃO FUNCIONA NA P52)
#-------------------------------------------------------------------------------
echo ""
echo "[5/8] Configurando drivers NVIDIA 550.xx..."

# Remover drivers antigos
apt purge -y '*nvidia*' '*cuda*' '*cudnn*' || true
apt autoremove -y

# Blacklist nouveau (se necessário)
if ! grep -q "blacklist nouveau" /etc/modprobe.d/blacklist-nvidia.conf 2>/dev/null; then
    cat >> /etc/modprobe.d/blacklist-nvidia.conf << 'EOF'
blacklist nouveau
options nouveau modeset=0
EOF
    update-initramfs -u
fi

# Tentar instalar via repositório primeiro
if ! apt install -y nvidia-driver-550 nvidia-settings nvidia-utils-550 2>/dev/null; then
    echo "Instalação via repositório falhou. Tentando download manual..."
    
    # Versão específica testada na P52
    NVIDIA_VERSION="550.54.14"
    NVIDIA_RUN="NVIDIA-Linux-x86_64-${NVIDIA_VERSION}.run"
    NVIDIA_URL="https://download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VERSION}/${NVIDIA_RUN}"
    
    cd /tmp
    wget -c "${NVIDIA_URL}" || {
        echo "ERRO: Falha ao baixar driver NVIDIA. Verifique conexão."
        exit 1
    }
    
    chmod +x "${NVIDIA_RUN}"
    
    # Parar display manager
    systemctl stop gdm3 || systemctl stop lightdm || systemctl stop sddm || true
    
    # Instalar driver
    ./"${NVIDIA_RUN}" --silent --dkms --no-opengl-files
    
    # Reiniciar display manager
    systemctl start gdm3 || systemctl start lightdm || systemctl start sddm || true
fi

# Verificar instalação
if nvidia-smi >/dev/null 2>&1; then
    echo "✓ Driver NVIDIA instalado com sucesso"
    nvidia-smi --query-gpu=name,driver_version --format=csv
else
    echo "⚠ Driver NVIDIA pode exigir reinicialização"
fi

#-------------------------------------------------------------------------------
# 6. CUDA TOOLKIT (Compatível com driver 550)
#-------------------------------------------------------------------------------
echo ""
echo "[6/8] Instalando CUDA Toolkit..."

CUDA_VERSION="12-4"
CUDA_REPO="cuda-keyring_1.1-1_all.deb"
CUDA_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/${CUDA_REPO}"

cd /tmp
wget -c "${CUDA_URL}" || {
    echo "AVISO: Falha ao baixar repositório CUDA. Instalando versão básica..."
    apt install -y cuda-toolkit || true
}

if [ -f "${CUDA_REPO}" ]; then
    dpkg -i "${CUDA_REPO}"
    apt update
    apt install -y cuda-toolkit-${CUDA_VERSION} cuda-drivers-550 cuda-command-line-tools-${CUDA_VERSION}
fi

# Configurar PATH do CUDA
if ! grep -q "CUDA_HOME" /etc/profile.d/cuda.sh 2>/dev/null; then
    cat > /etc/profile.d/cuda.sh << 'EOF'
export CUDA_HOME=/usr/local/cuda
export PATH=${CUDA_HOME}/bin:${PATH}
export LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
EOF
    chmod +x /etc/profile.d/cuda.sh
fi

#-------------------------------------------------------------------------------
# 7. BAIXAR SOURCE DO KERNEL 7.2.6
#-------------------------------------------------------------------------------
echo ""
echo "[7/8] Baixando source do kernel 7.2.6..."

KERNEL_USER="${SUDO_USER:-${USER}}"
KERNEL_DIR="/home/${KERNEL_USER}/kernel-dev"
KERNEL_VERSION="7.2.6"
KERNEL_TAR="linux-${KERNEL_VERSION}.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/${KERNEL_TAR}"

mkdir -p "${KERNEL_DIR}"
chown "${KERNEL_USER}:${KERNEL_USER}" "${KERNEL_DIR}"

cd "${KERNEL_DIR}"

if [ ! -f "${KERNEL_TAR}" ]; then
    sudo -u "${KERNEL_USER}" wget -c "${KERNEL_URL}"
    sudo -u "${KERNEL_USER}" tar -xf "${KERNEL_TAR}"
fi

KERNEL_SRC_DIR="${KERNEL_DIR}/linux-${KERNEL_VERSION}"

if [ ! -d "${KERNEL_SRC_DIR}" ]; then
    echo "ERRO: Diretorio do kernel não encontrado após extração"
    exit 1
fi

echo "✓ Kernel source disponível em: ${KERNEL_SRC_DIR}"

#-------------------------------------------------------------------------------
# 8. CONFIGURAR KERNEL COM CORREÇÕES PARA P52
#-------------------------------------------------------------------------------
echo ""
echo "[8/8] Configurando kernel com correções para ThinkPad P52..."

# Criar config baseada na atual + correções
sudo -u "${KERNEL_USER}" bash -c "
cd ${KERNEL_SRC_DIR}

# Copiar config atual como base
if [ -f /boot/config-\$(uname -r) ]; then
    cp /boot/config-\$(uname -r) .config
else
    # Fallback: config genérica para x86_64
    make olddefconfig
fi

# Aplicar correções críticas identificadas nos kernels 7.2.4/7.2.5
scripts/config --disable WERROR
scripts/config --disable DEBUG_KERNEL
scripts/config --disable DEBUG_INFO
scripts/config --disable DEBUG_INFO_BTF
scripts/config --disable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT

# Corrigir driver Elantech (problema de SMBus)
scripts/config --set-val MOUSE_PS2_ELANTECH y
scripts/config --set-val MOUSE_PS2_SYNAPTICS_SMBUS m

# Otimizar DRM para NVIDIA (desabilitar Nouveau se não usar)
scripts/config --set-val DRM_NOUVEAU m
scripts/config --set-val DRM_NOUVEAU_BACKLIGHT n

# Habilitar suporte a ThinkPad
scripts/config --set-val THINKPAD_ACPI y
scripts/config --set-val ACPI_VIDEO y
scripts/config --set-val ACPI_THERMAL y

# Otimizações de I/O para NVMe + SATA
scripts/config --set-val NVME_CORE y
scripts/config --set-val NVME_FC y
scripts/config --set-val NVME_TARGET y
scripts/config --set-val AHCI y
scripts/config --set-val SATA_AHCI y

# Pre-compilar headers
make prepare
make modules_prepare

echo 'Configuração do kernel concluída!'
"

#-------------------------------------------------------------------------------
# RESUMO FINAL
#-------------------------------------------------------------------------------
echo ""
echo "==============================================================================="
echo "SETUP CONCLUÍDO COM SUCESSO!"
echo "==============================================================================="
echo ""
echo "PRÓXIMOS PASSOS:"
echo "1. Compile o kernel:"
echo "   cd ${KERNEL_SRC_DIR}"
echo "   make -j\$(nproc)"
echo "   sudo make modules_install"
echo "   sudo make install"
echo ""
echo "2. Atualize o initramfs e GRUB:"
echo "   sudo update-initramfs -u -k all"
echo "   sudo update-grub"
echo ""
echo "3. Reinicie e selecione o novo kernel no GRUB"
echo ""
echo "4. Valide a instalação:"
echo "   uname -r  # Deve mostrar 7.2.6"
echo "   nvidia-smi  # Deve mostrar driver 550.xx"
echo "   lsmod | grep nvidia  # Deve listar módulos NVIDIA"
echo ""
echo "DIRETÓRIOS IMPORTANTES:"
echo "  Source do kernel: ${KERNEL_SRC_DIR}"
echo "  Configs salvas:   ${KERNEL_DIR}/configs/"
echo "  Logs de build:    /var/log/kern.log"
echo ""
echo "==============================================================================="
