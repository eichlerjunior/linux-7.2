# Setup Completo do Ambiente - ThinkPad P52 para Kernel 7.2.6

## Visão Geral
Este guia documenta a instalação completa do ambiente de desenvolvimento para compilar o kernel Linux 7.2.6 em um ThinkPad P52 com Pop!_OS, incluindo drivers NVIDIA 550.xx e CUDA.

## Problemas Identificados nos Kernels 7.2.4/7.2.5

### 1. **CONFIG_WERROR Habilitado**
- **Problema**: Transforma warnings em erros, quebrando a compilação
- **Solução**: `scripts/config --disable WERROR`

### 2. **DEBUG_KERNEL Ativo**
- **Problema**: Adiciona overhead significativo e pode causar instabilidade
- **Solução**: `scripts/config --disable DEBUG_KERNEL`

### 3. **Driver Elantech Touchpad**
- **Problema**: SMBus companion não inicializa corretamente
- **Sintoma**: Mensagem "SMbus companion is not ready yet"
- **Solução**: Forçar modo PS/2 tradicional
  ```bash
  scripts/config --set-val MOUSE_PS2_ELANTECH y
  scripts/config --set-val MOUSE_PS2_SYNAPTICS_SMBUS m
  ```

### 4. **Conflito DRM_NOUVEAU com NVIDIA**
- **Problema**: Driver open-source Nouveau conflita com driver proprietário
- **Solução**: 
  ```bash
  scripts/config --set-val DRM_NOUVEAU m
  scripts/config --set-val DRM_NOUVEAU_BACKLIGHT n
  ```

### 5. **Otimizações de I/O**
- **Problema**: Configuração subótima para sistemas NVMe + SATA
- **Solução**: Habilitar explicitamente AHCI e NVME_CORE

## Instalação Passo a Passo

### Pré-requisitos
- Pop!_OS 24.04 ou Ubuntu 24.04
- Acesso root/sudo
- Conexão com internet
- Mínimo 50GB livres em /home

### Executar Script de Setup

```bash
cd /workspace
sudo ./setup-ambiente-thinkpad-p52.sh
```

O script executará as seguintes etapas:

#### 1. Atualização do Sistema
```bash
apt update && apt upgrade -y
```

#### 2. Ferramentas de Compilação
Instala:
- build-essential, gcc, g++, make
- libncurses-dev, bison, flex
- libssl-dev, libelf-dev
- pahole, dwarves (para BTF)
- python3-dev, git, wget, curl
- ccache (para compilação incremental rápida)
- E diversas outras bibliotecas de desenvolvimento

#### 3. GCC Otimizado
Instala GCC 12 ou 13 (recomendado para kernel 7.2.x)

#### 4. LLVM/Clang (Opcional)
Para suporte a LTO e compilação híbrida

#### 5. Driver NVIDIA 550.xx
**CRÍTICO**: Versão 580 NÃO funciona na P52!

O script:
- Remove drivers antigos
- Blacklista nouveau
- Instala nvidia-driver-550 via repositório OU download manual
- Versão testada: 550.54.14

#### 6. CUDA Toolkit
- Instala CUDA 12.4 (compatível com driver 550)
- Configura variáveis de ambiente (CUDA_HOME, PATH, LD_LIBRARY_PATH)

#### 7. Download do Kernel 7.2.6
- Baixa source oficial de kernel.org
- Extrai em `/home/<usuario>/kernel-dev/linux-7.2.6`

#### 8. Configuração do Kernel
Aplica correções específicas para ThinkPad P52:
- Desabilita WERROR, DEBUG_KERNEL
- Configura driver Elantech
- Otimiza para NVIDIA
- Habilita recursos ThinkPad (ACPI, thermal)
- Otimiza I/O para NVMe + SATA

## Compilação do Kernel

Após o setup, compile o kernel:

```bash
cd /home/etl-bi/kernel-dev/linux-7.2.6

# Compilar (usa todos os cores disponíveis)
make -j$(nproc)

# Instalar módulos
sudo make modules_install

# Instalar kernel
sudo make install

# Atualizar initramfs e GRUB
sudo update-initramfs -u -k all
sudo update-grub
```

## Pós-Instalação

### Reiniciar e Selecionar Kernel
1. Reinicie a máquina
2. No menu GRUB, selecione "Linux 7.2.6"
3. Se não aparecer, segure SHIFT durante boot para mostrar GRUB

### Validação

```bash
# Verificar versão do kernel
uname -r  # Deve mostrar: 7.2.6

# Verificar driver NVIDIA
nvidia-smi  # Deve mostrar driver 550.xx

# Listar módulos NVIDIA
lsmod | grep nvidia

# Verificar touchpad
xinput list  # Deve mostrar "ETPS/2 Elantech Touchpad"

# Verificar discos
lsblk  # Deve mostrar NVMe + SATA
```

## Solução de Problemas

### Kernel não aparece no GRUB
```bash
sudo update-grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Driver NVIDIA falha após reboot
```bash
sudo dkms autoinstall
sudo update-initramfs -u
```

### Touchpad não responde
```bash
# Forçar recarga do módulo
sudo modprobe -r psmouse
sudo modprobe psmouse proto=imps
```

### Sistema trava durante compilação
- Reduza jobs paralelos: `make -j4` em vez de `make -j$(nproc)`
- Verifique temperatura: `watch -n 1 'sensors'`
- Limpe cache: `sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches`

## Estrutura de Diretórios

```
/home/etl-bi/kernel-dev/
├── linux-7.2.6/          # Source do kernel
│   ├── .config           # Configuração aplicada
│   ├── vmlinux           # Kernel compilado
│   └── arch/x86/boot/    # Imagens bootáveis
├── configs/              # Backups de configuração
└── logs/                 # Logs de compilação (criar manualmente)
```

## Referências

- [Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [NVIDIA Driver 550](https://www.nvidia.com/download/driverResults.aspx/xxx)
- [ThinkPad P52 Specs](https://psref.lenovo.com/syspool/Sys/PDF/ThinkPad/ThinkPad_P52.pdf)
- [Pop!_OS Wiki](https://pop.system76.com/docs)

## Notas Importantes

1. **Backup**: Sempre faça backup antes de instalar novo kernel
2. **Kernel Antigo**: Mantenha pelo menos um kernel funcional como fallback
3. **DKMS**: Módulos DKMS são recompilados automaticamente para novos kernels
4. **Secure Boot**: Pode precisar ser desabilitado para kernels customizados

## Contato e Suporte

Em caso de problemas específicos da P52, consulte:
- Fórum Pop!_OS: https://forum.pop-planet.fr/
- Reddit r/thinkpad: https://reddit.com/r/thinkpad
- Issue tracker deste repositório
