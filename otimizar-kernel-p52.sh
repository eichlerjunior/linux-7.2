#!/bin/bash
# =============================================================================
# Script de Otimização do Kernel 7.1.5 para ThinkPad P52
# Objetivo: Kernel monolítico, focado em Intel + NVIDIA CUDA, sem legado AMD
# =============================================================================

set -e

KERNEL_DIR="${HOME}/kernel-dev/linux-7.1.5"
CONFIG_FILE="${KERNEL_DIR}/.config"
BACKUP_FILE="${KERNEL_DIR}/.config.backup.original"

echo "========================================================================="
echo "OTIMIZAÇÃO DO KERNEL 7.1.5 PARA THINKPAD P52"
echo "========================================================================="
echo ""

# Verificar se o diretório do kernel existe
if [ ! -d "$KERNEL_DIR" ]; then
    echo "ERRO: Diretório do kernel não encontrado: $KERNEL_DIR"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERRO: Arquivo .config não encontrado em $CONFIG_FILE"
    exit 1
fi

# PASSO 1: BACKUP
echo "[1/6] Criando backup da configuração original..."
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "      Backup: $BACKUP_FILE"
echo ""

# PASSO 2: REMOVER SUPORTE AMD/ATI
echo "[2/6] Removendo suporte AMD/ATI legado..."
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

# PASSO 3: ADICIONAR DRIVERS CRÍTICOS
echo "[3/6] Adicionando drivers críticos..."
cat >> "$CONFIG_FILE" << 'EOF'

# === DRIVERS CRÍTICOS THINKPAD P52 ===
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_SND=y
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_CODEC_REALTEK=m
CONFIG_SND_HDA_CODEC_HDMI=m
CONFIG_E1000E=y
CONFIG_IWLWIFI=m
CONFIG_IWLMVM=m
CONFIG_BT=y
CONFIG_BT_HCIBTUSB=m
CONFIG_BT_INTEL=m
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_SATA_AHCI=y
CONFIG_FIRMWARE_LOADER=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_POWERCAP=y
CONFIG_INTEL_RAPL=m
CONFIG_ACPI_THINKPAD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_DRM_I915=y
CONFIG_DRM=y
CONFIG_FB=y
CONFIG_MODVERSIONS=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_TCG_TPM=y
CONFIG_INTEL_IOMMU=y
CONFIG_EXT4_FS=y
CONFIG_FUSE_FS=m
CONFIG_NTFS3_FS=m
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

# PASSO 4: REMOVER FS DESNECESSÁRIOS
echo "[4/6] Otimizando sistemas de arquivos..."
sed -i 's/^CONFIG_BTRFS_FS=y/# CONFIG_BTRFS_FS is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_XFS_FS=y/# CONFIG_XFS_FS is not set/' "$CONFIG_FILE"
echo "      OK"
echo ""

# PASSO 5: VALIDAÇÃO
echo "[5/6] Validando configurações..."
echo ""
echo "=== DRIVERS CRÍTICOS ==="
for opt in CONFIG_MOUSE_PS2_ELANTECH CONFIG_SND_HDA_INTEL CONFIG_NVME_CORE CONFIG_SATA_AHCI CONFIG_E1000E CONFIG_DRM_I915; do
    grep "^$opt=" "$CONFIG_FILE" && echo "  ✓ $opt" || echo "  ⚠ $opt NÃO ENCONTRADO"
done
echo ""
echo "=== SUPORTE AMD (deve estar desativado) ==="
AMD_ATIVO=$(grep -E "^CONFIG_CPU_SUP_AMD=|^CONFIG_DRM_AMDGPU=" "$CONFIG_FILE" | grep "=y" || true)
if [ -z "$AMD_ATIVO" ]; then
    echo "  ✓ AMD removido"
else
    echo "  ⚠ AMD ainda ativo:"
    echo "$AMD_ATIVO"
fi
echo ""

# PASSO 6: INSTRUÇÕES
echo "[6/6] PRÓXIMOS PASSOS"
echo "========================================================================="
echo ""
echo "1. Execute no diretório do kernel:"
echo "   cd $KERNEL_DIR"
echo "   make olddefconfig"
echo ""
echo "2. Compile (aproximadamente 30-45 minutos):"
echo "   make -j\$(nproc) deb-pkg LOCALVERSION=-p52"
echo ""
echo "3. Instale os pacotes .deb gerados em ~/kernel-dev/"
echo "   cd ~/kernel-dev"
echo "   sudo apt install ./linux-image-*.deb ./linux-headers-*.deb"
echo ""
echo "4. Atualize initramfs e GRUB:"
echo "   sudo update-initramfs -u -k all"
echo "   sudo update-grub"
echo ""
echo "5. Reinicie e selecione Linux 7.1.5-p52 no GRUB"
echo ""
echo "Backup salvo em: $BACKUP_FILE"
echo "========================================================================="
