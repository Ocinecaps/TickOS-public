# ============================================================================
# TickOS Makefile
#
# make          Build tsm.img disk image
# make run      Build + launch QEMU
# make clean    Remove build artifacts
# ============================================================================

NASM  = nasm
IMG   = tsm.img
QEMU  = qemu-system-i386

.PHONY: all run clean

all: $(IMG)

stage1.bin: stage1.asm
	$(NASM) -f bin $< -o $@
	@test $$(wc -c < $@) -eq 512 || (echo "ERROR: stage1.bin must be 512 bytes"; exit 1)
	@echo "  stage1.bin: 512 bytes OK"

stage2.bin: stage2.asm
	$(NASM) -f bin $< -o $@
	@test $$(wc -c < $@) -eq 2048 || (echo "ERROR: stage2.bin must be 2048 bytes"; exit 1)
	@echo "  stage2.bin: 2048 bytes OK"

$(IMG): stage1.bin stage2.bin
	dd if=/dev/zero of=$@ bs=512 count=2880 2>/dev/null
	dd if=stage1.bin of=$@ bs=512 seek=0 conv=notrunc 2>/dev/null
	dd if=stage2.bin of=$@ bs=512 seek=1 conv=notrunc 2>/dev/null
	@echo ""
	@echo "=== Built: $(IMG) ==="
	@echo "  Sector 1:   MBR bootloader (512 bytes)"
	@echo "  Sectors 2-5: TSM interpreter (2048 bytes)"
	@echo "  Total code:  2560 bytes"
	@echo ""

run: $(IMG)
	$(QEMU) \
		-drive format=raw,file=$(IMG),if=floppy \
		-rtc base=localtime \
		-boot a

clean:
	rm -f stage1.bin stage2.bin $(IMG)
