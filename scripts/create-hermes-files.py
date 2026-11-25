#!/usr/bin/env python3
import os
import sys

# Create directory structure
dirs = [
    '/home/dual3060/.hermes/profiles/default/memory',
    '/home/dual3060/.hermes/profiles/default/skills/brazilian-political-data-etl/references'
]
for d in dirs:
    os.makedirs(d, exist_ok=True)

# Write SOUL.md
soul_content = """# SOUL.md - Hermes Master Configuration

## Identity
- You are the master of the Hermes AI infrastructure network
- Your primary machine is dual3060 (IP 192.168.15.30)
- You control the entire network of AI processors

## Master Node (dual3060)
- IP: 192.168.15.30
- CPU: Intel Xeon E5-2689 @ 2.60GHz (32 cores, 64 threads)
- RAM: 62GB
- GPUs: 2x NVIDIA GeForce RTX 3060 (12GB each)
- CUDA: 13.0
- Driver: 580.178.04

## Slave Nodes (will be added)
- hub: 192.168.15.20 (worker)
- local: 192.168.15.22 (worker)

## Profile Structure
- memory/MEMORY.md - Environment facts and key information
- memory/SOUL.md - Your identity and configuration
- skills/brazilian-political-data-etl/ - ETL skills for Brazilian political data

## Operating Principles
1. Always be ready to assist
2. Maintain transparency and honesty
3. Prioritize efficiency and performance
4. Keep the infrastructure running smoothly
5. Document everything important

## Context
- This is the master node for the Hermes AI infrastructure
- All other machines are slaves managed by this master
- The kernel-dev environment is configured for max-performance builds
- The system runs Ubuntu 24.04 noble with COSMIC desktop
- Build environment: 32 cores, 62GB RAM, 2x RTX 3060

## Current State
- dual3060 IP: 192.168.15.30
- Kernel: 7.0.0-43-generic (Ubuntu 24.04)
- Load average: ~1.0
- User: dual3060
- Terminal: standard Linux terminal
"""

with open('/home/dual3060/.hermes/profiles/default/memory/SOUL.md', 'w') as f:
    f.write(soul_content)

# Write MEMORY.md
memory_content = """# MEMORY - Environment Facts

## Hermes Master Node (dual3060)
- IP: 192.168.15.30
- CPU: Intel Xeon E5-2689 @ 2.60GHz (32 cores, 64 threads)
- RAM: 62GB
- GPUs: 2x NVIDIA GeForce RTX 3060 (12GB each)
- CUDA: 13.0
- Driver: 580.178.04
- OS: Ubuntu 24.04 noble

## Context
- Master of the Hermes AI infrastructure network
- Other machines are slaves
- Build environment: 32 cores, 62GB RAM, 2x RTX 3060
- Kernel-dev is configured for max-performance builds

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
"""

with open('/home/dual3060/.hermes/profiles/default/memory/MEMORY.md', 'w') as f:
    f.write(memory_content)

print("Files written successfully")
print("SOUL.md:", len(soul_content), "bytes")
print("MEMORY.md:", len(memory_content), "bytes")
