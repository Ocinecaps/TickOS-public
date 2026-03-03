#!/bin/bash
# ============================================================================
# TickOS Build Script
# Assembles both stages and creates bootable floppy image
# ============================================================================
set -e

echo "=== TickOS Build ==="

echo "[1/2] Assembling stage1 (MBR)..."
nasm -f bin stage1.asm -o stage1.bin
echo "  $(wc -c < stage1.bin) bytes"

echo "[2/2] Assembling stage2 (interpreter)..."
nasm -f bin stage2.asm -o stage2.bin
echo "  $(wc -c < stage2.bin) bytes"

echo "Creating disk image..."
dd if=/dev/zero of=tsm.img bs=512 count=2880 2>/dev/null
dd if=stage1.bin of=tsm.img bs=512 seek=0 conv=notrunc 2>/dev/null
dd if=stage2.bin of=tsm.img bs=512 seek=1 conv=notrunc 2>/dev/null

echo ""
echo "=== Done: tsm.img ==="
echo ""
echo "Run with:"
echo "  qemu-system-i386 -drive format=raw,file=tsm.img,if=floppy -rtc base=localtime -boot a"
echo ""
echo "Or: make run"
