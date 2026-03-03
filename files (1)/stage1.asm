; ============================================================================
; TickOS Stage 1 — MBR Bootloader (sector 1, loaded at 0x7C00)
;
; Loads 4 sectors (2048 bytes) of stage2 from sectors 2-5 to 0x7E00.
; Then jumps to stage2 entry.
;
; Build:  nasm -f bin stage1.asm -o stage1.bin
; ============================================================================

[bits 16]
[org 0x7C00]

start:
    cli
    xor  ax, ax
    mov  ds, ax
    mov  es, ax
    mov  ss, ax
    mov  sp, 0x7C00

    mov  [boot_drive], dl     ; BIOS passes boot drive in DL

    ; Print banner
    mov  si, banner
.pr:
    lodsb
    or   al, al
    jz   .pr_done
    mov  ah, 0x0E
    xor  bh, bh
    int  0x10
    jmp  .pr
.pr_done:

    ; Reset disk controller
    xor  ax, ax
    mov  dl, [boot_drive]
    int  0x13
    jc   .try_floppy

    ; Load 4 sectors (stage2) at 0x7E00
    mov  ah, 0x02             ; read sectors
    mov  al, 4                ; 4 sectors = 2048 bytes
    mov  bx, 0x7E00           ; destination
    mov  cx, 0x0002           ; cylinder 0, sector 2
    mov  dh, 0x00             ; head 0
    mov  dl, [boot_drive]
    int  0x13
    jnc  .launch

.try_floppy:
    ; Fallback: try drive 0
    xor  ax, ax
    xor  dx, dx
    int  0x13
    mov  ah, 0x02
    mov  al, 4
    mov  bx, 0x7E00
    mov  cx, 0x0002
    xor  dx, dx
    int  0x13
    jnc  .launch

    ; Failed
    mov  si, err_msg
.ep:
    lodsb
    or   al, al
    jz   .halt
    mov  ah, 0x0E
    xor  bh, bh
    int  0x10
    jmp  .ep
.halt:
    cli
    hlt
    jmp  .halt

.launch:
    mov  dl, [boot_drive]
    jmp  0x0000:0x7E00

; Data
boot_drive  db 0x80
banner      db 'TickOS v1.0', 13, 10, 0
err_msg     db 'DISK ERR', 0

; Pad to 510 bytes + boot signature
times 510-($-$$) db 0
dw 0xAA55
