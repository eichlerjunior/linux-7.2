#!/bin/bash
set -e

KERNEL_DIR="${HOME}/kernel-dev/linux-7.3"
CONFIG_FILE="${KERNEL_DIR}/.config"
BACKUP_FILE="${KERNEL_DIR}/.config.backup.original"

echo "========================================================================="
echo "FORJA DE KERNEL MONOLÍTICO 7.3 PARA THINKPAD P52"
echo "========================================================================="
echo ""

if [ ! -d "$KERNEL_DIR" ]; then
    echo "ERRO: Diretório do kernel não encontrado: $KERNEL_DIR"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERRO: Arquivo .config não encontrado em $CONFIG_FILE"
    exit 1
fi

echo "[1/7] Criando backup da configuração original..."
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "      Backup: $BACKUP_FILE"
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
    echo "  ✓ AMD removido"
else
    echo "  ⚠ AMD ainda ativo:"
    echo "$AMD_ATIVO"
fi
echo ""

echo "[6/7] Versionamento no GitHub..."
echo "Lembre-se de submeter este script e o log da compilação para o repositório no GitHub para garantir o rastreamento da matriz."
echo ""

echo "[7/7] EXECUÇÃO DA COMPILAÇÃO"
echo "========================================================================="
echo ""
echo "Execute os seguintes comandos para iniciar a forja:"
echo "1. cd $KERNEL_DIR"
echo "2. make olddefconfig"
echo "3. make -j36 deb-pkg LOCALVERSION=-p52"
echo "4. cd ~/kernel-dev"
echo "5. sudo apt install ./linux-image-7.3.0-p52*.deb ./linux-headers-7.3.0-p52*.deb"
echo ""
echo "========================================================================="
