#!/bin/bash
set -e

echo "[+] 1. Ajustando limites de memória compartilhada do kernel..."
sudo sysctl -w kernel.shmmax=34359738368
sudo sysctl -w kernel.shmall=8388608
echo "kernel.shmmax=34359738368" | sudo tee /etc/sysctl.d/99-postgresql-ram.conf > /dev/null
echo "kernel.shmall=8388608" | sudo tee /etc/sysctl.d/99-postgresql-ram.conf > /dev/null

echo "[+] 2. Parando instâncias órfãs e recriando o RAMFS limpo..."
sudo -u postgres /usr/lib/postgresql/18/bin/pg_ctl -D /mnt/ramdisk/postgres stop 2>/dev/null || true
sudo rm -rf /mnt/ramdisk/postgres
sudo mkdir -p /mnt/ramdisk/postgres
sudo chown -R postgres:postgres /mnt/ramdisk/postgres
sudo chmod 700 /mnt/ramdisk/postgres

echo "[+] 3. Inicializando o cluster PostgreSQL 18 no RAMFS..."
sudo -u postgres /usr/lib/postgresql/18/bin/initdb -D /mnt/ramdisk/postgres

echo "[+] 4. Injetando parâmetros de alta performance (128GB RAM & RTX A2000)..."
sudo tee -a /mnt/ramdisk/postgres/postgresql.conf > /dev/null << 'CONF_EOF'

# Ajustes de alta performance para cluster local em RAMFS (128GB RAM)
listen_addresses = 'localhost'
port = 5432
max_connections = 100
shared_buffers = 16GB
effective_cache_size = 64GB
work_mem = 256MB
maintenance_work_mem = 1GB
synchronous_commit = on
full_page_writes = on
bonjour = off
ssl = off

# Ajustes do PG-Strom para 4GB VRAM (NVIDIA RTX A2000)
pg_strom.enabled = on
pg_strom.chunk_size = 64MB
CONF_EOF

sudo chown postgres:postgres /mnt/ramdisk/postgres/postgresql.conf

echo "[+] 5. Iniciando o servidor PostgreSQL na RAM..."
sudo -u postgres /usr/lib/postgresql/18/bin/pg_ctl -D /mnt/ramdisk/postgres -l /mnt/ramdisk/postgres/logfile start

echo "[+] Concluído com sucesso absoluto!"
