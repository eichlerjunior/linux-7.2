#!/bin/bash
source $(dirname "$0")/llvm_extreme_profile.sh
source "$HOME/.cargo/env"

echo "[+] Forjando aplicativos base da distribuição via Cargo/LLVM..."
# Alacritty (Terminal GPU), Zellij (Multiplexador), Helix (Editor modal)
cargo install alacritty zellij helix --locked --root /usr/local
echo "[+] Aplicativos Rust instalados em /usr/local/bin (Prioridade absoluta no PATH)"
