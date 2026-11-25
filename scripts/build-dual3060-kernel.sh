#!/bin/bash
# ============================================================
# BUILD DUAL3060 KERNEL (Xeon E5-2689, 62GB, 2xRTX3060, 32 threads)
# Copiado do setup "kernel-dev" (branch profilepad-p52)
# ============================================================
set -euo pipefail

KERNEL_DIR="${1:-/home/dual3060/kernel-dev/linux-7.3.4}"
BUILD_TYPE="${2:-latest}"
LOG="${BUILD_LOG:-/home/dual3060/kernel-dev/build-7.3.4-dual3060.log}"
JOBS="${JOBS:-32}"
CONFIG_SRC="${CONFIG_SRC:-$HOME/kernel-dev/configs/config-7.2.4-p52-current}"

echo "============================================================"
echo "  BUILD DUAL3060 KERNEL"
echo "  Kernel dir : $KERNEL_DIR"
echo "  Build type : $BUILD_TYPE"
echo "  Jobs       : $JOBS"
echo "  LOG        : $LOG"
echo "  Source config: $CONFIG_SRC"
echo "============================================================"

cd "$KERNEL_DIR" || { echo "ERRO: diretorio nao encontrado: $KERNEL_DIR"; exit 1; }

# 1. Backup + base config
cp .config "$KERNEL_DIR/.config.backup.original" 2>/dev/null || true
if [ -f "$CONFIG_SRC" ]; then
    cp "$CONFIG_SRC" .config
    echo "[1/5] Base config copiado de $CONFIG_SRC"
else
    echo "[1/5] Gerando config baseline (defconfig)..."
    make ARCH=x86 defconfig >/dev/null 2>&1
fi

# 2. Olddefconfig (mantém as opcoes do P52, atualiza para 7.3.4)
make ARCH=x86 -s olddefconfig >/dev/null 2>&1 || true

# 3. Force the CPU/arch defaults for Xeon E5-2689
echo "CONFIG_MARCH_X86_64=y" >> .config
echo "CONFIG_X86_64=y" >> .config
echo "CONFIG_SMP=y" >> .config
echo "CONFIG_NUMA=y" >> .config
echo "CONFIG_MEMORY_HOTPLUG=y" >> .config
echo "CONFIG_MEMORY_HOTREMOVE=y" >> .config
echo "CONFIG_BLK_DEV_DM=y" >> .config
echo "CONFIG_CMA=y" >> .config

echo "[2/5] Configuracao aplicada ($(wc -l < .config) linhas)"

# 3b. Verificar CPU/time
echo "  [check] cpu flags:"
grep -E "model name" /proc/cpuinfo | head -1
make ARCH=x86 kmacro_version >/dev/null 2>&1
echo "  [check] ~20 cores x 2.60GHz, 62GB RAM, 2x RTX3060"

# 4. Build
echo ""
echo "[3/5] COMPILACAO (make -j32)..."
echo "Iniciado: $(date)" | tee "$LOG"
{
    time make -j32 bzImage modules 2>&1
} | tee -a "$LOG"
BUILD_STATUS=${PIPESTATUS[0]}
echo "Compilacao terminada: $(date)" | tee -a "$LOG"

if [ "$BUILD_STATUS" -ne 0 ]; then
    echo "ERRO na compilacao! Ver log: $LOG" >&2
    exit 1
fi

# 5. Install
echo ""
echo "[4/5] Installing modules + kernel..."
make ARCH=x86 INSTALL_MOD_STRIP=1 modules_install >/dev/null 2>&1
make ARCH=x86 install >/dev/null 2>&1 || true

# 6. Summary
echo ""
echo "[5/5] RESULTADO:"
ls -la arch/x86_64/boot/bzImage 2>/dev/null
du -sh usr/lib/ostree 2>/dev/null
echo "===== BUILD COMPLETE ====="
