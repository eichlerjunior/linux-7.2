#!/bin/bash
# =============================================================================
# Otimização de Hardware para ThinkPad P52 (128GB RAM, NVMe, Quadro P2000)
# =============================================================================

set -e

echo "[1/3] Configurando paginação e cache na RAM (sysctl)..."
sudo bash -c "cat << 'EOF' > /etc/sysctl.d/99-p52-tuning.conf
# Forçar uso total da RAM de 128GB antes do SWAP (proteção do NVMe)
vm.swappiness=1
# Reduzir acúmulo de cache para mitigar gargalos de I/O
vm.dirty_background_ratio=2
vm.dirty_ratio=5
EOF"
sudo sysctl --system > /dev/null
echo "      OK"
echo ""

echo "[2/3] Configurando escalonador I/O do NVMe (udev)..."
sudo bash -c "cat << 'EOF' > /etc/udev/rules.d/60-nvme-scheduler.rules
# Delegar gerenciamento de fila de I/O para a controladora de hardware NVMe
ACTION==\"add|change\", KERNEL==\"nvme[0-9]*n[0-9]*\", ATTR{queue/scheduler}=\"none\"
EOF"
sudo udevadm control --reload-rules
sudo udevadm trigger
echo "      OK"
echo ""

echo "[3/3] Ativando persistência do driver NVIDIA (systemd)..."
sudo bash -c "cat << 'EOF' > /etc/systemd/system/nvidia-persistence-mode.service
[Unit]
Description=NVIDIA GPU Persistence Mode
After=syslog.target network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF"
sudo systemctl daemon-reload
sudo systemctl enable --now nvidia-persistence-mode.service
echo "      OK"
echo ""

echo "========================================================================="
echo "Otimizações aplicadas com sucesso. Parâmetros persistentes gerados."
echo "========================================================================="
