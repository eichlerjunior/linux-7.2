#!/bin/bash

KERNEL_VERSION=$(uname -r)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR=~/kernel-dev/benchmarks
OUTPUT_FILE=$OUTPUT_DIR/benchmark_${KERNEL_VERSION}_${TIMESTAMP}.txt

mkdir -p $OUTPUT_DIR

echo "=== BENCHMARK KERNEL $KERNEL_VERSION ===" | tee $OUTPUT_FILE
echo "Data: $(date)" | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

# 1. Informações do sistema
echo "--- INFORMAÇÕES DO SISTEMA ---" | tee -a $OUTPUT_FILE
uname -a | tee -a $OUTPUT_FILE
cat /proc/cpuinfo | grep "model name" | head -1 | tee -a $OUTPUT_FILE
free -h | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

# 2. Tempo de boot
echo "--- TEMPO DE BOOT ---" | tee -a $OUTPUT_FILE
systemd-analyze | tee -a $OUTPUT_FILE
systemd-analyze blame | head -10 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

# 3. CPU Performance (sysbench)
echo "--- CPU PERFORMANCE ---" | tee -a $OUTPUT_FILE
if command -v sysbench &> /dev/null; then
    sysbench cpu --cpu-max-prime=10000 --threads=4 run 2>&1 | tee -a $OUTPUT_FILE
else
    echo "sysbench não instalado, usando alternativa" | tee -a $OUTPUT_FILE
    time for i in {1..10000}; do echo "test" > /dev/null; done 2>&1 | tee -a $OUTPUT_FILE
fi
echo "" | tee -a $OUTPUT_FILE

# 4. Memory Bandwidth (dd test)
echo "--- MEMORY BANDWIDTH ---" | tee -a $OUTPUT_FILE
dd if=/dev/zero of=/tmp/testfile bs=1M count=1024 oflag=dsync 2>&1 | tee -a $OUTPUT_FILE
rm -f /tmp/testfile
echo "" | tee -a $OUTPUT_FILE

# 5. Disk I/O (fio se disponível, senão dd)
echo "--- DISK I/O ---" | tee -a $OUTPUT_FILE
if command -v fio &> /dev/null; then
    fio --name=randread --ioengine=libaio --iodepth=1 --rw=randread --bs=4k --direct=1 --size=1G --numjobs=4 --runtime=10 --group_reporting 2>&1 | tee -a $OUTPUT_FILE
else
    echo "fio não instalado, usando dd" | tee -a $OUTPUT_FILE
    dd if=/dev/zero of=/tmp/testfile bs=1M count=512 conv=fdatasync 2>&1 | tee -a $OUTPUT_FILE
    rm -f /tmp/testfile
fi
echo "" | tee -a $OUTPUT_FILE

# 6. Network Latency
echo "--- NETWORK LATENCY ---" | tee -a $OUTPUT_FILE
ping -c 10 8.8.8.8 2>&1 | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

# 7. Módulos carregados
echo "--- MÓDULOS CARREGADOS ---" | tee -a $OUTPUT_FILE
lsmod | wc -l | tee -a $OUTPUT_FILE
lsmod | grep -E "nvidia|drm|i915" | tee -a $OUTPUT_FILE
echo "" | tee -a $OUTPUT_FILE

echo "Benchmark completo salvo em: $OUTPUT_FILE"
