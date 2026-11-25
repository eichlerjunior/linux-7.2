#!/bin/bash

RAMDIR="/mnt/ramdisk/postgres"
echo "[+] Configurando o cluster PostgreSQL Lite em RAMFS (Utilizando parte dos 128GB de RAM)..."

# Cria a estrutura na RAM se não existir
sudo mkdir -p $RAMDIR
sudo chown -R postgres:postgres /mnt/ramdisk 2>/dev/null || sudo chown -R $USER:$USER $RAMDIR

# Inicializa o banco de dados diretamente na RAM
/usr/local/pgsql-lite/bin/initdb -D $RAMDIR

echo "[+] Otimizando parâmetros do postgresql.conf para hardware local de alta performance (128GB RAM)..."
cat << 'EOF_CONF' >> $RAMDIR/postgresql.conf
# Ajustes focados em isolamento local e uso massivo de RAM
listen_addresses = 'localhost'
port = 5432
max_connections = 100

# Uso de memória otimizado para o ThinkPad P52
shared_buffers = 32GB          # 25% dos 128GB disponíveis dedicados ao cache de dados
effective_cache_size = 96GB    # Estimativa de cache do sistema operacional
work_mem = 256MB               # Memória para ordenações e joins complexos por operação
maintenance_work_mem = 2GB     # Memória para operações de manutenção (VACUUM, CREATE INDEX)

# Desativa recursos de rede externos desnecessários (Zero I/O externo)
bonjour = off
ssl = off
EOF_CONF

echo "[+] Cluster PostgreSQL Lite estruturado na RAM com sucesso."
