#!/bin/bash
source $(dirname "$0")/llvm_extreme_profile.sh

echo "[+] Clonando e forjando llama.cpp com aceleração CUDA nativa..."
cd /tmp
rm -rf llama.cpp
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp

# Compilação C++ forçando a arquitetura Pascal da Quadro P2000 (Compute 6.1)
make -j$(nproc) LLAMA_CUDA=1 LLAMA_CUDA_NVCC=/usr/local/cuda/bin/nvcc CUDA_DOCKER_ARCH=compute_61

sudo cp llama-cli llama-server /usr/local/bin/
echo "[+] Motor de inferência SOPHIA ancorado em /usr/local/bin"
