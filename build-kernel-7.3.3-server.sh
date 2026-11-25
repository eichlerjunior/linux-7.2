#!/bin/bash
# =============================================================================
# FORJA DE KERNEL 7.3.3 - SERVIDOR GAME/MEDIA 192.168.15.20
# ======================================
# Perfil:
#   CPU:  Intel Xeon E5-2697 v2 @ 2.70GHz (24 threads, 24 cores)
#   RAM: 62GB
#   GPU:  NVIDIA GTX 1050 Ti (gaming, nvidia-driver 580)
#   DISK: 1.9T SSD
#   NET:  Realtek RTL8111 1Gbps
#
# Compilacao: LLVM=1 -j24
# Parametros: CC=clang LLVM=1 LOCALVERSION=-gaming
# Arquitetura: x86_64
# =============================================================================
set -e

KERNEL_DIR="${HOME}/kernel-dev/linux-7.3.3"
cd "${KERNEL_DIR}"

echo "========================================================================="
echo " FORJA KERNEL 7.3.3 - SERVER GAME/MEDIA 192.168.15.20"
echo "========================================================================="
echo "  CPU: Intel Xeon E5-2697 v2 @ 2.70GHz (24 threads, 24 cores)"
echo "  RAM: 62GB"
echo "  GPU: NVIDIA GTX 1050 Ti"
echo "  Threads: 24"
echo "  Dir: ${KERNEL_DIR}"
echo ""

# [1/5] Limpar configuracao e objetos anteriores
echo "[1/5] make mrproper..."
make mrproper

# [2/5] Base a partir da configuracao do sistema atual
echo "[2/5] Base: cp /boot/config-$(uname -r) .config"
cp "/boot/config-$(uname -r)" .config

# [3/5] Injetar drivers criticos e arquivosystems em modo monolitico (=y)
cat >> .config << 'EOF'

# === DRIVERS CRITICOS SERVER (MONOLITICO) ===
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_SND=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_E1000E=y
CONFIG_IWLWIFI=y
CONFIG_IWLMVM=y
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
CONFIG_MODULES=y
CONFIG_MODVERSIONS=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_TCG_TPM=y
CONFIG_INTEL_IOMMU=y

# === ARQUIVOSYSTEMS MONOLITICOS (leitura/gravacao maxima) ===
CONFIG_EXT4_FS=y
CONFIG_FUSE_FS=y
CONFIG_NTFS3_FS=y
CONFIG_EXFAT_FS=y
CONFIG_EXFAT_FS_POSIX_NAMES=y
CONFIG_F2FS_FS=y
CONFIG_UDF_FS=y
CONFIG_UDF_RW=y
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZFS_FS=y
CONFIG_ZFS_POSIX_ACL=y
CONFIG_ZFS_TRANSLATION=y
CONFIG_ZFS_USERQUOTA=y
CONFIG_ZFS_XATTR_ACL=y
CONFIG_ZFS_DTRACE=y
CONFIG_ZFS_HOSTID=y
CONFIG_ZFS_ZIL=y
CONFIG_ZFS_POSIX_LOCKS=y
CONFIG_ZFS_DIAGNOSTIC=y
CONFIG_ZFS_DONT_MASK=y
CONFIG_ZFS_POOL_HISTORY=y
CONFIG_ZFS_OVERLAY=y
CONFIG_ZFS_REFQUOTA=y
CONFIG_ZFS_IOSTATS=y
CONFIG_ZFS_RECORDSIZE=1M
CONFIG_ZFS_LOGSIZE=2M
CONFIG_APFS_FS=y
CONFIG_APFS_FS_POSIX_ACL=y
CONFIG_APFS_FS_XATTR=y

# === Criptografia e seguranca ===
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_BLAKE2S=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_OBFUSCILGEN=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_CURVE25519=y
CONFIG_CRYPTO_ADDREST=y
CONFIG_CRYPTO_SHASH=y
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_STD_DEFLATE=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO=y
CONFIG_LZO_INFLATE=y
CONFIG_XZ_HOST=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_SINGLE=y

# === SUPORTE A LINGUAGEM (BCEDIC e grandes codificacoes) ===
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_UTF8=y
CONFIG_UNIAMAP=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_KOI8R=y
CONFIG_NLS_KOI8RGB=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_CP437=y
CONFIG_NLS_ISO646=y
CONFIG_NLS_UTF8=y
CONFIG_NLS_UTF16=y
CONFIG_NLS_UTF16BE=y
CONFIG_NLS_UTF16LE=y
CONFIG_NLS_UTF32=y
CONFIG_NLS_UTF32BE=y
CONFIG_NLS_UTF32LE=y
CONFIG_NLS_BCC=y
CONFIG_NLS_GB18030=y
CONFIG_NLS_GB2312=y
CONFIG_NLS_JOHAB=y
CONFIG_NLS_HZ=y
CONFIG_NLS_HZ_1000=y

# === ARQUITETURA ===
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
CONFIG_BPF_SYSCALL=y
CONFIG_PERF_EVENTS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
EOF
echo "      Footer injetado."

# [4/5] Bloquear todo WIFI EXTERNO (seguranca)
cat >> .config << 'EOF'

# === BLOQUEIO DE WIFI EXTERNA (seguranca) ===
CONFIG_RT2X00=n
CONFIG_RTL8192CE=n
CONFIG_RTL8192SE=n
CONFIG_RTL8192DE=n
CONFIG_RTL8723AE=n
CONFIG_RTL8723BE=n
CONFIG_RTL8188EE=n
CONFIG_RTL8192EE=n
CONFIG_RTL8821AE=n
CONFIG_RTL8192CU=n
CONFIG_RTL8192DU=n
CONFIG_RTLWIFI=n
CONFIG_RTLWIFI_PCI=n
CONFIG_RTLWIFI_USB=n
CONFIG_RTL8192C_COMMON=n
CONFIG_RTL8192D_COMMON=n
CONFIG_RTL8723_COMMON=n
CONFIG_RTLBTCOEXIST=n
CONFIG_RTL8XXXU=n
CONFIG_RTL8XXXU_UNTESTED=n
CONFIG_RTW88=n
CONFIG_RTW88_CORE=n
CONFIG_RTW88_PCI=n
CONFIG_RTW88_SDIO=n
CONFIG_RTW88_USB=n
CONFIG_RTW88_8822B=n
CONFIG_RTW88_8822C=n
CONFIG_RTW88_8723X=n
CONFIG_RTW88_8703B=n
CONFIG_RTW88_8723D=n
CONFIG_RTW88_8821C=n
CONFIG_RTW88_88XXA=n
CONFIG_RTW88_8821A=n
CONFIG_RTW88_8812A=n
CONFIG_RTW88_8814A=n
CONFIG_RTW88_8822BE=n
CONFIG_RTW88_8822BS=n
CONFIG_RTW88_8822BU=n
CONFIG_RTW88_8822CE=n
CONFIG_RTW88_8822CS=n
CONFIG_RTW88_8822CU=n
CONFIG_RTW88_8723DE=n
CONFIG_RTW88_8723DS=n
CONFIG_RTW88_8723CS=n
CONFIG_RTW88_8723DU=n
CONFIG_RTW88_8821CE=n
CONFIG_RTW88_8821CS=n
CONFIG_RTW88_8821CU=n
CONFIG_RTW88_8821AU=n
CONFIG_RTW88_8812AU=n
CONFIG_RTW88_8814AE=n
CONFIG_RTW88_8814AU=n

# === Bloqueio complementar de servicos nao criticos (seguranca) ===
CONFIG_UEVENT_HELPER=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_LOG_BUF_STACK=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_TIMEOUT=10
EOF
echo "      Wifi externa bloqueada."

# [5/5] Validar configuracao
echo "[5/5] make LLVM=1 olddefconfig (validacao)"
make LLVM=1 olddefconfig

echo ""
echo "=== VERIFICACAO FINAL DA CONFIGURACAO ==="
echo "  Wifi interno (Intel CNVi):"
echo "    IWLWIFI  (interior): $(grep "^CONFIG_IWLWIFI=" .config | cut -d= -f2)"
echo "    IWLMVM   (interior): $(grep "^CONFIG_IWLMVM=" .config | cut -d= -f2)"
echo "    CFG80211 (interior): $(grep "^CONFIG_CFG80211=" .config | cut -d= -f2)"
echo "  Arquivosystems:"
echo "    EXT4_FS  (mono)   : $(grep "^CONFIG_EXT4_FS=" .config | cut -d= -f2)"
echo "    NTFS3_FS (mono)   : $(grep "^CONFIG_NTFS3_FS=" .config | cut -d= -f2)"
echo "    ZFS_FS   (mono)   : $(grep "^CONFIG_ZFS_FS=" .config | cut -d= -f2)"
echo "    APFS_FS  (mono)   : $(grep "^CONFIG_APFS_FS=" .config | cut -d= -f2)"
echo "    EXFAT_FS (mono)   : $(grep "^CONFIG_EXFAT_FS=" .config | cut -d= -f2)"
echo "    F2FS_FS  (mono)   : $(grep "^CONFIG_F2FS_FS=" .config | cut -d= -f2)"
echo "  Wifi externo (bloqueado):"
echo "    RTL8XXXU (exterior): $(grep "^CONFIG_RTL8XXXU=" .config | cut -d= -f2)"
echo "    RTW88    (exterior): $(grep "^CONFIG_RTW88=" .config | cut -d= -f2)"
echo "  Surfos de linguagem:"
echo "    NLS   (ativo)     : $(grep "^CONFIG_NLS=" .config | cut -d= -f2)"
echo "    UTF8  (ativo)     : $(grep "^CONFIG_UTF8=" .config | cut -d= -f2)"
echo "    BCC   (Big5)      : $(grep "^CONFIG_NLS_BCC=" .config | cut -d= -f2)"
echo "    GB18030 (ativo)   : $(grep "^CONFIG_NLS_GB18030=" .config | cut -d= -f2)"
echo ""

# [6/6] Compilacao
echo "[6/6] make LLVM=1 -j24 bzImage modules (compilacao)..."
echo "      Nao pare durante a compilacao..."
make LLVM=1 -j24 bzImage modules
echo ""
echo "========================================================================="
echo "[✓] COMPILACAO CONCLUIDA!"
echo "      ${KERNEL_DIR}/vmlinuz-7.3.3-gaming"
echo "      ${KERNEL_DIR}/modules/"
echo "========================================================================="
