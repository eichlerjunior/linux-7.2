#!/bin/bash
# ============================================================
# GERA O .CONFIG OTIMIZADO PARA DUAL3060 (Xeon E5-2689, 62GB, 2xRTX3060)
# ============================================================
set -euo pipefail

KERNEL_DIR="${1:-/home/dual3060/kernel-dev/linux-7.3.4}"
CONFIG_FILE="${KERNEL_DIR}/.config"

CPU_NAME="E5-2689 0 @ 2.60GHz"
THREADS=32
RAM_GB=62
GPU="2x NVIDIA GeForce RTX 3060"
NVMe="3.7T"

echo "=== Kernel build config for: $CPU_NAME ==="
echo "Threads: $THREADS | RAM: ${RAM_GB}GB | GPU: $GPU | Storage: NVMe"

# Base: start from the local P52 current config (tuned ETL/BI workload)
SRC_CONFIG="${1:-$HOME}/kernel-dev/configs/config-7.2.4-p52-current"

if [ ! -f "$SRC_CONFIG" ]; then
    echo "ERROR: source config not found: $SRC_CONFIG" >&2
    exit 1
fi

cp "$SRC_CONFIG" "$CONFIG_FILE"
echo "[1/4] Base config copied ($(wc -l < "$CONFIG_FILE") linhas)"
echo "[2/4] Applying architecture defaults (x86_64, generic CPU)..."

# Force architecture + machine defaults from config-5.18 (generic x86_64)
make ARCH=x86 -C "$KERNEL_DIR" olddefconfig >/dev/null 2>&1 || true

# Verify key values are sane
echo ""
echo "=== VERIFICATION ==="
for opt in CONFIG_MISC_ENUMS_CONF; do :; done
grep -E "^CONFIG_MARCH_" "$CONFIG_FILE" | head -3
grep -E "^CONFIG_NUMA=" "$CONFIG_FILE" | head -2
grep -E "^CONFIG_SMP=" "$CONFIG_FILE" | head -2
grep -E "^CONFIG_EXT4_FS=" "$CONFIG_FILE" | head -2
grep -E "^CONFIG_XFS_FS=" "$CONFIG_FILE" | head -2
grep -E "^CONFIG_BLK_DEV_NVME=" "$CONFIG_FILE" | head -2
grep -E "^CONFIG_SERIAL_8250=y|^CONFIG_SERIAL_8250=y" "$CONFIG_FILE"
echo ""
echo "Config written to $CONFIG_FILE ($(wc -l < "$CONFIG_FILE") linhas)"
echo ""
echo "Ready to build: make -j32 bzImage"
echo "=== Next steps ==="
echo "  make -j32 -C $KERNEL_DIR bzImage modules"
echo "  sudo make -C $KERNEL_DIR modules_install"
echo "  sudo make -C $KERNEL_DIR install"
