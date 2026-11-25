#!/bin/bash
# MAX-COMPUTE kernel build for dual3060 (Xeon E5-2689, 32 cores, 62GB, 2x RTX 3060)
# Profile: NO ACPI, NO POWER MANAGEMENT, MAX-CPU-USE

set -euo pipefail

SRC=/home/dual3060/kernel-dev/linux-7.3.4
OUT=/home/dual3060/kernel-build/7.3.4-maxperf
JOBS=32

echo "=== MAX-COMPUTE KERNEL BUILD ==="
echo "Date: $(date)"
echo "Source: $SRC"
echo "Output: $OUT"
echo "Jobs: $JOBS"

cd "$SRC"

# Clean and prepare
make clean 2>/dev/null || true
make mrproper 2>/dev/null || true

# Copy config from local profile
cp /home/dual3060/kernel-dev/config-7.2.4-p52-current .config 2>/dev/null || true

# Configure with max-compute profile
echo "=== Configuring MAX-COMPUTE kernel ==="

# Ensure console is available
scripts/config --enable CONFIG_VT
scripts/config --enable CONFIG_VT_CONSOLE

# CPU: max performance, no power management
scripts/config --set-str CONFIG_SMP 1
scripts/config --enable CONFIG_SMP
scripts/config --set-str CONFIG_NR_CPUS 32
scripts/config --set-str CONFIG_NODES_SHIFT 0
scripts/config --enable CONFIG_HUGETLB_PAGE
scripts/config --disable CONFIG_HIGHMEM64G

# Power management: REMOVE ALL
scripts/config --disable CONFIG_ACPI
scripts/config --disable CONFIG_ACPI_PROCESSOR
scripts/config --disable CONFIG_PM
scripts/config --disable CONFIG_PM_SLEEP
scripts/config --disable CONFIG_PM_STD_PARTS
scripts/config --disable CONFIG_PM_DRIVERS
scripts/config --disable CONFIG_PM_LEGACY
scripts/config --disable CONFIG_PM_STAY_AWAKE

# No drivers for power
scripts/config --disable CONFIG_REGULATOR
scripts/config --disable CONFIG_CPU_IDLE

# No audio/video
scripts/config --disable CONFIG_SND

# Network power management
scripts/config --disable CONFIG_WIRELESS
scripts/config --disable CONFIG_NETDEVICES
scripts/config --disable CONFIG_NET_CORE

# Build
echo "=== Building kernel ==="
make -j$JOBS bzImage modules 2>&1 | tee /home/dual3060/kernel-build/7.3.4-maxperf/build.log

echo "=== Installing modules ==="
make modules_install INSTALL_MOD_PATH=/home/dual3060/kernel-build/7.3.4-maxperf 2>&1 | tee -a /home/dual3060/kernel-build/7.3.4-maxperf/build.log

echo "=== Installing kernel ==="
cp arch/x86/boot/bzImage /home/dual3060/kernel-build/7.3.4-maxperf/vmlinuz
cp System.map /home/dual3060/kernel-build/7.3.4-maxperf/
echo "BUILD COMPLETE"
