#!/bin/bash
source $(dirname "$0")/llvm_extreme_profile.sh

echo "[+] Instalando dependências de sistema para PostgreSQL, PostGIS e LLVM/CUDA..."
sudo apt-get install -y libreadline-dev zlib1g-dev libssl-dev libxml2-dev libxslt1-dev libsystemd-dev gettext pkg-config libproj-dev libgeos-dev libgdal-dev

# Diretório temporário de compilação
WORK_DIR="/tmp/postgres-gpu-forge"
mkdir -p $WORK_DIR
cd $WORK_DIR

echo "[+] Baixando o código-fonte do PostgreSQL..."
PG_VERSION="16.3"
wget -q -c https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.gz
tar -xf postgresql-$PG_VERSION.tar.gz
cd postgresql-$PG_VERSION

echo "[+] Configurando compilação nativa com LLVM e otimizações de silício..."
# Apontamos para o diretório do CUDA Toolkit para o PG-Strom compilar os kernels paralelos
export CUDA_PATH="/usr/local/cuda"
export PATH="$CUDA_PATH/bin:$PATH"

./configure \
    CC=clang \
    CXX=clang++ \
    --prefix=/usr/local/pgsql \
    --with-llvm \
    --with-python \
    --with-openssl \
    --with-libxml \
    --with-libxslt

echo "[+] Compilando o PostgreSQL em paralelo (Força Máxima)..."
make -j$(nproc)
sudo make install

echo "[+] Criando links simbólicos em /usr/local/bin..."
sudo ln -sf /usr/local/pgsql/bin/* /usr/local/bin/

echo "[+] PostgreSQL com suporte a LLVM compilado e ancorado."
