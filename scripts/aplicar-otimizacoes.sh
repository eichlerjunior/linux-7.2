#!/bin/bash
echo "🔧 Aplicando otimizações manuais ao kernel..."

# ============================================
# 1. REMOVER HARDWARE LEGADO
# ============================================
echo "   → Removendo hardware legado..."
scripts/config --disable CONFIG_BLK_DEV_FD
scripts/config --disable CONFIG_PARPORT
scripts/config --disable CONFIG_ISA
scripts/config --disable CONFIG_MCA
scripts/config --disable CONFIG_EISA

# ============================================
# 2. REMOVER DRIVERS DE REDE DESNECESSÁRIOS
# ============================================
echo "   → Removendo drivers de rede extras..."
scripts/config --disable CONFIG_ATM
scripts/config --disable CONFIG_IPX
scripts/config --disable CONFIG_APPLETALK
scripts/config --disable CONFIG_WAN
scripts/config --disable CONFIG_ARCNET
scripts/config --disable CONFIG_FDDI
scripts/config --disable CONFIG_HIPPI
scripts/config --disable CONFIG_PLIP
scripts/config --disable CONFIG_SLIP

# ============================================
# 3. REMOVER SISTEMAS DE ARQUIVOS NÃO USADOS
# ============================================
echo "   → Mantendo apenas EXT4 e essenciais..."
scripts/config --disable CONFIG_BTRFS_FS
scripts/config --disable CONFIG_XFS_FS
scripts/config --disable CONFIG_REISERFS_FS
scripts/config --disable CONFIG_JFS_FS
scripts/config --disable CONFIG_OCFS2_FS
scripts/config --disable CONFIG_GFS2_FS
scripts/config --disable CONFIG_AFS_FS
scripts/config --disable CONFIG_NILFS2_FS
scripts/config --disable CONFIG_F2FS_FS

# ============================================
# 4. REMOVER DEBUG E TRACING
# ============================================
echo "   → Removendo debug e tracing..."
scripts/config --disable CONFIG_DEBUG_KERNEL
scripts/config --disable CONFIG_DEBUG_FS
scripts/config --disable CONFIG_DEBUG_MISC
scripts/config --disable CONFIG_KGDB
scripts/config --disable CONFIG_UBSAN
scripts/config --disable CONFIG_KASAN
scripts/config --disable CONFIG_KCOV
scripts/config --disable CONFIG_FTRACE
scripts/config --disable CONFIG_FUNCTION_TRACER
scripts/config --disable CONFIG_DYNAMIC_FTRACE

# ============================================
# 5. OTIMIZAÇÕES DE PERFORMANCE
# ============================================
echo "   → Aplicando otimizações de performance..."
scripts/config --enable CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE
scripts/config --disable CONFIG_CC_OPTIMIZE_FOR_SIZE
scripts/config --set-val CONFIG_HZ 1000
scripts/config --enable CONFIG_SCHED_AUTOGROUP

# ============================================
# 6. REMOVER DRIVERS DE ENTRADA DESNECESSÁRIOS
# ============================================
echo "   → Removendo drivers de entrada extras..."
scripts/config --disable CONFIG_JOYSTICK
scripts/config --disable CONFIG_TABLET_USB
scripts/config --disable CONFIG_TOUCHSCREEN

# ============================================
# 7. REMOVER VIRTUALIZAÇÃO (se não usar)
# ============================================
echo "   → Removendo virtualização..."
scripts/config --disable CONFIG_KVM
scripts/config --disable CONFIG_VIRTUALIZATION
scripts/config --disable CONFIG_XEN

# ============================================
# 8. REMOVER DRIVERS DE ÁUDIO EXTRAS
# ============================================
echo "   → Removendo drivers de áudio extras..."
scripts/config --disable CONFIG_SND_DRIVERS
scripts/config --disable CONFIG_SND_ISA
scripts/config --disable CONFIG_SND_PCI
scripts/config --disable CONFIG_SND_USB

# ============================================
# 9. VALIDAR CONFIGURAÇÃO
# ============================================
echo "   → Validando configuração..."
make olddefconfig

echo "✅ Otimizações aplicadas com sucesso!"
