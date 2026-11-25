#!/bin/bash
source $(dirname "$0")/llvm_extreme_profile.sh

# Diretório de forja em memória/temporário
BUILD_DIR="/tmp/gnu-forge"
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Definição das versões estáveis do core GNU
COREUTILS_VER="9.5"
GREP_VER="3.11"
SED_VER="4.9"
GAWK_VER="5.3.0"
FINDUTILS_VER="4.9.0"

# Função universal de forja C (GNU Make)
forge_gnu_module() {
    local NAME=$1
    local VERSION=$2
    local URL="https://ftp.gnu.org/gnu/$NAME/$NAME-$VERSION.tar.xz"

    echo "[+] ========================================================"
    echo "[+] Forjando Módulo: $NAME v$VERSION"
    echo "[+] ========================================================"
    
    wget -q -c $URL
    tar -xf "$NAME-$VERSION.tar.xz"
    cd "$NAME-$VERSION"

    # Configuração de build:
    # --prefix=/usr/local: Garante precedência no $PATH (sobrepõe o APT)
    # --disable-nls: Remove suporte multilíngue para diminuir footprint na RAM e maximizar IPC
    ./configure CC=clang CXX=clang++ --prefix=/usr/local --disable-nls

    echo "[+] Compilando $NAME (Fat LTO + AVX)..."
    make -j$(nproc)

    echo "[+] Instalando binários na arquitetura local..."
    make install
    cd ..
}

echo "[+] Iniciando a Forja do Espaço de Usuário GNU (SOPHIA OS)..."

# Elevação estrita interna para o comando 'make install' que escreve em /usr/local
forge_gnu_module "coreutils" "$COREUTILS_VER"
forge_gnu_module "grep" "$GREP_VER"
forge_gnu_module "sed" "$SED_VER"
forge_gnu_module "gawk" "$GAWK_VER"
forge_gnu_module "findutils" "$FINDUTILS_VER"

echo "[+] Forja GNU concluída. O sistema operacional agora opera utilitários base no silício nativo."
