#!/bin/bash
set -e
KERNEL_VERSION="7.2.4"
KERNEL_DIR="$HOME/kernel-dev/linux-${KERNEL_VERSION}"

cd "$KERNEL_DIR" || { echo "Diretório não encontrado"; exit 1; }

echo "==> 1. Limpando artefatos de build anteriores (mantendo o fonte)"
make clean

echo "==> 2. Copiando config base do kernel em execução"
cp /boot/config-$(uname -r) .config

echo "==> 3. REMOVENDO drivers desnecessários (RTL e ISH)"
scripts/config --set-val CONFIG_BT_RTL n
scripts/config --set-val CONFIG_INTEL_ISH_HID n
scripts/config --set-val CONFIG_INTEL_ISH_FIRMWARE_DOWNLOADER n
scripts/config --set-val CONFIG_INTEL_ISHTP_ECLITE n

echo "==> 4. Resolvendo dependências de configuração"
yes "" | make olddefconfig

echo "==> 5. Compilando e gerando pacotes .deb (sem baixar nada)"
make -j$(nproc) bindeb-pkg

echo "==> SUCESSO: Pacotes .deb gerados em ~/kernel-dev/"
