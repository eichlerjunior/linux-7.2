#!/bin/bash
# =============================================================================
# Perfil Monolítico LLVM/Clang para a Distribuição Interna SOPHIA
# =============================================================================

# Forçando o compilador LLVM para toda a esteira C/C++
export CC=clang
export CXX=clang++

# Flags de silício e otimização para C/C++ (-march=native, O3, LTO)
export CFLAGS="-march=native -O3 -flto=thin -fno-plt -pipe"
export CXXFLAGS="-march=native -O3 -flto=thin -fno-plt -pipe"
export LDFLAGS="-Wl,-O2,--sort-common,--as-needed,-z,relro,-z,now,-fuse-ld=mold"

# Flags de força bruta e bypass do Cargo.toml para Rust
export CARGO_PROFILE_RELEASE_LTO="fat"
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS="1"
export CARGO_PROFILE_RELEASE_PANIC="abort"
export CARGO_PROFILE_RELEASE_STRIP="true"
export CARGO_PROFILE_RELEASE_OPT_LEVEL="3"
export RUSTFLAGS="-C target-cpu=native -C link-arg=-fuse-ld=mold -A warnings"

echo "[+] Perfil LLVM Extreme carregado na memória."
