# Compilacao do Kernel Linux 7.2.4 para Pop!_OS (e derivados)

Este repositorio documenta o processo de compilacao do kernel 7.2.4 (versao oficial do kernel.org) em um sistema Pop!_OS 24.04 (COSMIC), com otimizacoes para hardware moderno (Lenovo P52, i7, 128GB RAM, NVMe, GPU dedicada). O objetivo e fornecer um script funcional e uma documentacao passo a passo que possa ser reutilizada em outras maquinas.

## Indice

- Visao Geral
- Pre-requisitos
- Script de Compilacao Final
- Erros Encontrados e Solucoes
- Passos para Compilar em Outra Maquina
- Instalacao e Atualizacao do Bootloader
- Verificacao e Reinicializacao
- Contribuicao

---

## Visao Geral

Este projeto automatiza a compilacao do kernel 7.2.4, baixado diretamente do kernel.org, aplicando:

- Reducao de drivers desnecessarios (hardware legado, sistemas de arquivos nao usados, debug, tracing).
- Otimizacoes de performance (HZ=1000, scheduler autogroup, otimizacao para performance em vez de tamanho).
- Suporte a NVMe e placa de video dedicada (Nouveau).
- Geracao de pacotes .deb para instalacao limpa no Pop!_OS (ou qualquer Debian/Ubuntu).
- Certificados dummy para evitar erros de assinatura de modulos.
- Uso de todos os nucleos da CPU (nproc).

O script foi testado no Pop!_OS 24.04 com systemd-boot, mas e compativel com GRUB tambem.

---

## Pre-requisitos

Antes de compilar, instale as dependencias:

sudo apt update && sudo apt install -y \
    build-essential libncurses-dev bison flex libssl-dev \
    bc dwarves zstd rsync libelf-dev libdw-dev libdwarf-dev \
    gawk debhelper

Nota: O gawk e necessario para gerar modules.builtin.ranges; o dwarves fornece pahole (necessario para BTF).

---

## Script de Compilacao Final

O script principal e build-kernel-7.2.4.sh. Ele faz:

1. Limpeza completa (make clean, make mrproper).
2. Copia da configuracao do kernel atual (/boot/config-$(uname -r)).
3. Reducao de drivers via localmodconfig.
4. Otimizacoes manuais com scripts/config.
5. Criacao de certificados dummy (para contornar erros de assinatura).
6. Compilacao paralela (-j$(nproc)).
7. Geracao de pacotes .deb com make bindeb-pkg.

O script esta disponivel neste repositorio.

---

## Erros Encontrados e Solucoes

Durante o processo, enfrentamos e resolvemos os seguintes erros:

| Erro | Causa | Solucao |
|------|-------|---------|
| fatal error: dwarf.h | Faltando cabecalhos do libdwarf | sudo apt install libdwarf-dev |
| fatal error: gelf.h / libelf.h | Faltando libelf-dev | sudo apt install libelf-dev |
| gawk: not found | O sistema usava mawk, mas o kernel requer gawk | sudo apt install gawk |
| bad command: CONFIG_PARPORT | Sintaxe incorreta no scripts/config (varias opcoes na mesma linha sem \) | Corrigido com quebras de linha explicitas (\) entre cada opcao. |
| debian/canonical-revoked-certs.pem nao encontrado | O build espera certificados para assinatura de modulos | Criados arquivos dummy com touch e desabilitada CONFIG_SYSTEM_REVOCATION_LIST. |
| No rule to make target debian/canonical-revoked-certs.pem | O mesmo problema acima | Correcao com certificados dummy. |
| W: Possible missing firmware ... (NVIDIA) | O driver nouveau embutido busca firmware proprietario | Aviso inofensivo; pode ser ignorado ou pode-se instalar o driver NVIDIA proprietario depois. |
| Modulo system76_acpi pulado no DKMS | BUILD_EXCLUSIVE nao corresponde ao kernel | Isso e esperado; o modulo nao e necessario para este hardware. |

---

## Passos para Compilar em Outra Maquina

1. Clone este repositorio:
   git clone https://github.com/eichlerjunior/linux-7.2.git
   cd linux-7.2

2. Baixe o codigo-fonte do kernel 7.2.4 (se nao estiver incluso):
   wget https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.2.4.tar.xz
   tar -xf linux-7.2.4.tar.xz

3. Instale as dependencias (veja a secao de pre-requisitos).

4. Ajuste o caminho no script (se necessario) e de permissao:
   chmod +x build-kernel-7.2.4.sh

5. Execute:
   ./build-kernel-7.2.4.sh

6. Instale os pacotes gerados:
   sudo dpkg -i /home/eichlerjr/kernel-dev/linux-*.deb

7. Reinicie e selecione o novo kernel no boot menu.

---

## Instalacao e Atualizacao do Bootloader

No Pop!_OS com systemd-boot, a instalacao do pacote .deb ja atualiza automaticamente o bootloader. Em sistemas com GRUB, o pacote tambem executara update-grub. Se precisar forcar uma atualizacao manual:

- Para systemd-boot:
  sudo bootctl update
- Para GRUB:
  sudo update-grub

---

## Verificacao e Reinicializacao

Apos reiniciar, confirme a versao:

uname -r
# Deve mostrar: 7.2.4

Caso o sistema nao inicie com o novo kernel, voce pode voltar ao anterior selecionando a entrada antiga no menu de boot.

---

## Contribuicao

Sinta-se a vontade para abrir issues ou pull requests com melhorias. Este script pode ser adaptado para outras versoes do kernel (basta alterar a variavel KERNEL_VERSION e o link de download).

Licenca: MIT
