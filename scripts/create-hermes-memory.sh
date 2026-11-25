# MEMORY - Environment Facts

## Hermes Master Node (dual3060)
- IP: 192.168.15.30 (master)
- CPU: Intel Xeon E5-2689 @ 2.60GHz (32 cores, 64 threads)
- RAM: 62GB
- GPUs: 2x NVIDIA GeForce RTX 3060 (12GB each)
- CUDA: 13.0
- Driver: 580.178.04
- OS: Ubuntu 24.04 noble

## Context
- This is the MAESTRO/PRIMARY machine of the Hermes AI infrastructure
- Other machines will be SLAVES of this master
- Build environment: 32 cores, 62GB RAM, 2x RTX 3060
- Kernel-dev environment is configured for max-performance builds
- OS: Ubuntu 24.04 noble with COSMIC desktop

## Build Environment
- Kernel: 7.0.0-43-generic (Ubuntu 24.04)
- Current load: ~1.0
- User: dual3060
- Terminal: standard Linux terminal

## Network
- 192.168.15.30 (master)
- 192.168.15.20 (hub - worker)
- 192.168.15.22 (local - worker)

## GPU Configuration
- 0: NVIDIA GeForce RTX 3060 (12GB)
- 1: NVIDIA GeForce RTX 3060 (12GB)
- Driver: 580.178.04
- CUDA: 13.0
- Max compute: disabled ACPI, no power management

## Tasks
- Build latest kernel for max performance
- Set up AI server
- Ambient/AI-home infrastructure
- Portuguese-speaking environment
- Kernel build: maxperf profile

## Key Commands
- ssh dual3060@192.168.15.30 (master)
- Build kernel: scripts/build-dual3060-maxperf.sh
- CUDA: installed 13.0.88
HERMEMY_MD
echo "MEMORY.md created"