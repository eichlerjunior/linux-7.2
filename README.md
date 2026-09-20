# Linux Kernel 7.2.x Otimizado para Lenovo P52 (Workstation ETL/BI)

> **Objetivo**: Fornecer kernels Linux 7.2.4, 7.2.5 e 7.2.6 totalmente otimizados para estações de trabalho Lenovo (P52, P53, P72, etc.) focadas em ETL, BI e Virtualização, resolvendo problemas crônicos de hardware que as distribuições padrão ignoram.

## 🚧 Por que este repositório?

Durante a montagem de uma workstation de alta performance (Lenovo P52, i7 8ª Gen, 128GB RAM) para processos de ETL e BI, enfrentamos **inúmeras frustrações** com kernels genéricos:
- ❌ **Teclado/TrackPoint**: Funcionamento intermitente ou perda de funcionalidades macro.
- ❌ **Leitor Biométrico (Fingerprint)**: Quase nunca funciona "out-of-the-box".
- ❌ **Áudio**: Falhas no dock, HDMI ou codecs Realtek específicos.
- ❌ **Filesystems**: Suporte pobre a NTFS (leitura/escrita) e APFS (Mac) necessário para dual-boot/trabalho híbrido.
- ❌ **Performance**: Kernels genéricos não aproveitam 128GB de RAM nem CPUs Coffee Lake corretamente.

Este repositório documenta a **jornada de compilação**, os erros encontrados e as **soluções aplicadas** via configuração customizada do kernel (`config`) e patches, resultando em um sistema estável e extremamente rápido.

---

## 🖥️ Hardware Alvo e Suporte

Este kernel é compilado especificamente para a arquitetura **Coffee Lake (Intel 8ª/9ª Gen)**, mas mantém compatibilidade ampla.

### Lenovo ThinkPad P52 (Principal)
- **CPU**: Intel Core i7-8850H / Xeon E-2176M (Otimizado com `-march=skylake`)
- **RAM**: 128GB (Otimizado com Transparent HugePages & NUMA Balancing)
- **GPU**: NVIDIA Quadro P2000 (Drivers proprietários suportados) + Intel UHD 630
- **Armazenamento**: NVMe PCIe + Segundo Disco NTFS (Suporte Leitura/Escrita Nativo)
- **Periféricos Críticos**:
    - ✅ **Teclado/TrackPoint**: Correção de taxa de amostragem e macros.
    - ✅ **Fingerprint**: Suporte a leitores Validity/Synaptics habilitado.
    - ✅ **Áudio**: Dolby Audio, Docking Station, HDMI e USB-C Audio.
    - ✅ **Câmera**: IR e Webcam tradicional funcionando.
    - ✅ **Leitores**: SD Card, SmartCard e USB 3.1.

### Outros Hardwares Lenovo Testados
- ThinkPad P53 / P72 / P73
- ThinkPad T480 / T490 / X1 Carbon (6ª/7ª Gen)

---

## 📦 Versões Disponíveis

| Versão | Status | Descrição | Uso Recomendado |
|--------|--------|-----------|-----------------|
| **7.2.4** | ✅ Estável | Versão base validada. Todas as correções de hardware aplicadas. | Produção Atual |
| **7.2.5** | 🧪 Testes | Melhorias de rede e correções menores de drivers. | Homologação |
| **7.2.6** | 🚀 Release | Otimizações finais de I/O para XFS e ETL. | Produção Futura |

---

## 🛠️ Soluções de Problemas Comuns (Troubleshooting)

Aqui documentamos o que foi corrigido manualmente nestes kernels:

### 1. Teclado e TrackPoint
- **Problema**: Teclas repetindo, trackpoint travando ou sem scroll médio.
- **Solução**: Habilitado `CONFIG_MOUSE_PS2_TRACKPOINT=y`, ajustes de `atkbd` e parâmetros de boot `i8042.reset`.

### 2. Leitor Biométrico (Fingerprint)
- **Problema**: Dispositivo não listado ou sem driver no kernel padrão.
- **Solução**: Compilado suporte a `CONFIG_FINGERPRINT` e drivers específicos `validity-sensor` e `fprintd`.

### 3. Filesystems NTFS e APFS
- **Problema**: NTFS apenas leitura; APFS incompatível.
- **Solução**: 
    - **NTFS**: Driver `ntfs3` (Paragon) compilado nativamente para leitura/escrita de alta velocidade.
    - **APFS**: Módulos externos da comunidade Paragon suportados (headers incluídos).

### 4. Áudio e Docking
- **Problema**: Sem som ao conectar dock ou saída HDMI muda sozinha.
- **Solução**: ALSA configurado com codecs Realtek ALC32xx completos e suporte a múltiplos dispositivos de áudio simultâneos.

### 5. Virtualização (KVM/QEMU)
- **Problema**: Lentidão em VMs ou falha ao passar dispositivos USB.
- **Solução**: `CONFIG_KVM_INTEL`, `VFIO`, `IOMMU` habilitados e otimizados para baixa latência.

---

## 🚀 Guia de Instalação Rápida

### Pré-requisitos
- Sistema base: Pop!_OS 24.04 / Ubuntu 24.04 (Derivados Debian)
- Dependências: `build-essential`, `libncurses-dev`, `bison`, `flex`, `libssl-dev`, `libelf-dev`

### Passo 1: Baixar e Instalar
Os pacotes `.deb` pré-compilados estão disponíveis nas [Releases](https://github.com/eichlerjunior/linux-7.2/releases) ou podem ser compilados localmente.

```bash
# Baixe os pacotes da versão desejada (ex: 7.2.4)
wget https://github.com/eichlerjunior/linux-7.2/releases/download/v7.2.4/linux-image-7.2.4*.deb
wget https://github.com/eichlerjunior/linux-7.2/releases/download/v7.2.4/linux-headers-7.2.4*.deb

# Instale
sudo dpkg -i linux-image-7.2.4*.deb linux-headers-7.2.4*.deb

# Atualize o GRUB e reinicie
sudo update-grub
sudo reboot
```

### Passo 2: Validação Pós-Instalação
Verifique se as otimizações estão ativas:

```bash
# Verificar governor de CPU (deve ser performance)
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Verificar algoritmo de TCP (deve ser bbr)
sysctl net.ipv4.tcp_congestion_control

# Verificar HugePages
cat /sys/kernel/mm/transparent_hugepage/enabled
```

---

## ⚙️ Compilação Local (Para Usuários Avançados)

Se desejar compilar o kernel com suas próprias modificações:

1. Clone o repositório:
   ```bash
   git clone https://github.com/eichlerjunior/linux-7.2.git
   cd linux-7.2
   ```

2. Baixe o source do kernel oficial (kernel.org) e extraia na pasta correspondente (`linux-7.2.x`).

3. Execute o script de build automatizado:
   ```bash
   # Para a versão 7.2.4
   ./build-kernel-7.2.4.sh

   # Para a versão 7.2.5
   ./build-kernel-7.2.5.sh
   
   # Para a versão 7.2.6
   ./build-kernel-7.2.6.sh
   ```
   *O processo leva aproximadamente 30-45 minutos em um i7 com SSD NVMe.*

4. Os pacotes `.deb` serão gerados na raiz do diretório.

---

## 📝 Notas de Versão e Changelog

### v7.2.6 (Mais Recente)
- [ADICIONADO] Otimizações específicas para workload ETL (XFS logbufs aumentados).
- [FIX] Correção de estabilidade em interfaces de rede 10Gbps.
- [UPDATE] Baseado no upstream 7.2.6 estável.

### v7.2.5
- [FIX] Melhoria na detecção de docks USB-C durante suspensão/hibernação.
- [UPDATE] Drivers WiFi Intel AX200/AX210 atualizados.

### v7.2.4 (Base)
- [INIT] Lançamento inicial com todas as correções de hardware do P52.
- [FIX] Resolução definitiva do problema do TrackPoint e Teclado.
- [FEATURE] Suporte completo a NTFS3 e APFS.

---

## 🤝 Contribuição e Agradecimentos

Este projeto nasceu da necessidade de uma estação de trabalho confiável para dados críticos. Se você possui um Lenovo ThinkPad e enfrentou problemas similares, sinta-se à vontade para testar e reportar.

**Autor**: etl-bi (Eichler Junior)  
**Licença**: GPL v2 (Mesma licença do Kernel Linux)  
**Inspiração**: Comunidade Linux-Hardware e Kernel.org

---
*Documentação reconstruída baseada em testes reais de hardware e compilação.*
