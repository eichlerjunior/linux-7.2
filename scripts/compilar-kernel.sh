#!/bin/bash
# ============================================================
# Script Automático de Compilação do Kernel 7.2.2
# Sem interação humana - Todas respostas pré-definidas
# ============================================================

set -e

echo "🚀 INICIANDO COMPILAÇÃO AUTOMÁTICA DO KERNEL"
echo "============================================"
date

# 1. Limpa tudo
echo "[1/8] Limpando compilações anteriores..."
make clean
make mrproper

# 2. Copia configuração base
echo "[2/8] Copiando configuração do kernel atual..."
cp /boot/config-$(uname -r) .config

# 3. Executa localmodconfig com respostas automáticas
echo "[3/8] Executando localmodconfig..."
yes "" | make localmodconfig > /dev/null 2>&1 || true
yes "" | make olddefconfig > /dev/null 2>&1 || true

# 4. Desabilita drivers problemáticos
echo "[4/8] Desabilitando drivers problemáticos..."
scripts/config --disable CONFIG_VIDEO_HWS
scripts/config --disable CONFIG_VIDEO_DEV
scripts/config --disable CONFIG_MEDIA_SUPPORT
scripts/config --disable CONFIG_DRM
scripts/config --disable CONFIG_DRM_I915
scripts/config --disable CONFIG_FB
scripts/config --disable CONFIG_FRAMEBUFFER_CONSOLE
scripts/config --disable CONFIG_DEBUG_KERNEL
scripts/config --disable CONFIG_DEBUG_FS
scripts/config --disable CONFIG_FTRACE

# 5. Habilita console básico
echo "[5/8] Configurando console básico..."
scripts/config --enable CONFIG_VGA_CONSOLE
scripts/config --enable CONFIG_DUMMY_CONSOLE
scripts/config --enable CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE
scripts/config --disable CONFIG_CC_OPTIMIZE_FOR_SIZE

# 6. Cria certificados
echo "[6/8] Criando certificados..."
mkdir -p debian
openssl req -new -x509 -newkey rsa:2048 -sha256 -nodes \
  -keyout certs/signing_key.pem \
  -out certs/signing_key.pem \
  -days 365 \
  -subj "/CN=Kernel" 2>/dev/null || true
cp certs/signing_key.pem debian/canonical-revoked-certs.pem 2>/dev/null || true
cp certs/signing_key.pem debian/canonical-certs.pem 2>/dev/null || true
touch debian/canonical-revoked-certs.pem
touch debian/canonical-certs.pem

# 7. Valida configuração (sem interação)
echo "[7/8] Validando configuração..."
yes "" | make olddefconfig > /dev/null 2>&1 || true

# 8. Compila
echo "[8/8] Compilando kernel..."
echo "⏳ Isso pode levar de 30 minutos a 2 horas..."
make -j4

echo "============================================"
echo "✅ COMPILAÇÃO CONCLUÍDA COM SUCESSO!"
date
