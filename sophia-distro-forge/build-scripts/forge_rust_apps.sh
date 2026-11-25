#!/bin/bash
source $(dirname "$0")/llvm_extreme_profile.sh
source "$HOME/.cargo/env"

echo "[+] Limpando o cache de artefatos corrompidos do Cargo e do Helix..."
rm -rf /tmp/cargo-install*
rm -rf /tmp/helix/target
cargo cache -a

# ==============================================================================
# A Diretiva de Aniquilação do LTO para o Cargo Workspace Misto
# ==============================================================================
# Forçamos LTO off tanto nas variáveis do Cargo quanto no linker argument.
export CARGO_PROFILE_RELEASE_LTO="off"
export RUSTFLAGS="-C target-cpu=native -C link-arg=-fuse-ld=mold -C link-arg=-Wl,-fno-lto -A warnings"
export CFLAGS="-march=native -O3 -fno-lto -pipe"
export CXXFLAGS="-march=native -O3 -fno-lto -pipe"

echo "[+] Compilando Zellij (Multiplexador de terminais)..."
cargo install zellij --locked --root /usr/local

echo "[+] Compilando Helix (Editor modal) a partir do source master..."
cd /tmp/helix
cargo install --path helix-term --locked --root /usr/local

# Instala os arquivos runtime (temas, sintaxe) obrigatórios do Helix
sudo mkdir -p /usr/local/lib/helix
sudo cp -r runtime /usr/local/lib/helix/

echo "[+] Forja dos Aplicativos Core concluída. Binários injetados em /usr/local/bin"
