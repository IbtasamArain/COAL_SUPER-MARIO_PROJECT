; ============================================================
; sprites.asm - Module 4: Sprite drawing
; Include this file once, after defs.asm and the shared data.
;
; DrawSprite calling convention:
;   push flags
;   push sprite_address
;   push y
;   push x
;   call DrawSprite
; Flags: bit 0 = mirror horizontally; bit 1 = blink (skip on odd tick);
;        bit 2 = 16x32 sprite (otherwise 16x16).
; Colour index 0 is transparent.
; draw_seg must contain the segment to draw into (normally 0xA000
; until the frame-buffer module is integrated).
; ============================================================

SPRITE_W equ 16
SPRITE_H equ 16
SPRITE_SUPER_H equ 32

; ------------------------------------------------------------
; DrawSprite
; Purpose: draw a 16x16 sprite, or 16x32 when flags bit 2 is set.
; Inputs: stack x, y, address, flags (push flags/address/y/x).
; Outputs: none.
; Registers changed: none (all general and segment registers preserved).
; ------------------------------------------------------------
DrawSprite:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, [draw_seg]
    mov es, ax
    mov si, [bp+8]          ; sprite address in caller's DS
    mov ax, ds
    mov ds, ax
    mov bx, [bp+4]          ; x
    mov dx, [bp+6]          ; y
    mov cx, 16              ; width
    test word [bp+10], 4
    jz .height_ready
    mov cx, 32
.height_ready:
    push cx                 ; height counter
    xor di, di              ; row index
.row:
    pop cx
    or cx, cx
    jz .done
    push cx
    xor ax, ax
    mov al, [si]            ; placeholder read below; SI advanced per pixel
    ; Calculate destination y and reject rows outside 0..199.
    mov ax, dx
    add ax, di
    cmp ax, 0
    jl .next_row
    cmp ax, SCREEN_H
    jge .next_row
    ; Compute row base = (y+row)*320 + x using 256+64.
    mov ax, dx
    add ax, di
    mov bp, ax              ; temporary row y
    shl ax, 8
    mov cx, bp
    shl cx, 6
    add ax, cx
    add ax, bx
    mov bp, ax              ; destination row base
    mov cx, 16
    xor ah, ah
.pixel:
    ; Source column is mirrored when flag bit 0 is set.
    mov ax, di
    ; Pixel index in row: use an inner counter stored in DX temporarily.
    ; SI always advances in normal order; mirrored rows are read backwards
    ; by selecting source offset from the row base.
    ; Recompute source byte using row*16 + source column.
    ; Keep destination column in DX.
    push cx
    mov cx, 16
    ; This branch is intentionally replaced by the indexed loop below.
    pop cx
    jmp .pixel_loop
.pixel_loop:
    ; Use DI as row and CX as column counter; source index = row*16 + col.
    ; The mirrored case changes source column only.
    mov ax, di
    shl ax, 4
    mov dx, 16
    sub dx, cx
    test word [bp+10], 1
    jz .normal_col
    mov dx, cx
    dec dx
.normal_col:
    add ax, dx
    mov dl, [si+ax]
    or dl, dl
    jz .skip_pixel
    ; destination = row_base + (16-cx)
    mov ax, bp
    mov dx, 16
    sub dx, cx
    add ax, dx
    cmp ax, 0
    jl .skip_pixel
    cmp ax, 64000
    jae .skip_pixel
    mov [es:ax], dl
.skip_pixel:
    loop .pixel_loop
.next_row:
    inc di
    pop cx
    dec cx
    push cx
    jmp .row
.done:
    pop cx
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8

; ------------------------------------------------------------
; Original simple 16x16 pixel-art sprites.
; Values are VGA palette indexes; zero is transparent.
; ------------------------------------------------------------
sprite_mario_stand:
    db 0,0,0,4,4,4,4,4,4,4,0,0,0,0,0,0
    db 0,0,4,4,4,4,4,4,4,4,4,4,0,0,0,0
    db 0,0,6,6,6,14,14,14,14,14,0,0,0,0,0,0
    db 0,6,14,6,14,14,14,14,14,14,14,0,0,0,0,0
    db 0,6,14,6,6,14,14,14,14,14,14,14,0,0,0,0
    db 0,0,6,14,14,14,14,14,14,14,0,0,0,0,0,0
    db 0,0,0,14,14,14,14,14,14,0,0,0,0,0,0,0
    db 0,0,4,4,1,4,4,4,1,4,4,0,0,0,0,0
    db 0,4,4,4,1,4,4,4,1,4,4,4,0,0,0,0
    db 0,4,4,4,1,1,1,1,1,4,4,4,0,0,0,0
    db 0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0
    db 0,0,0,6,6,6,0,6,6,6,0,0,0,0,0,0
    db 0,0,6,6,6,6,0,6,6,6,6,0,0,0,0,0
    db 0,0,6,6,6,0,0,0,6,6,6,0,0,0,0,0
    db 0,0,6,6,0,0,0,0,0,6,6,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

sprite_mario_run:
    db 0,0,0,4,4,4,4,4,4,4,0,0,0,0,0,0
    db 0,0,4,4,4,4,4,4,4,4,4,4,0,0,0,0
    db 0,0,6,6,6,14,14,14,14,14,0,0,0,0,0,0
    db 0,6,14,6,14,14,14,14,14,14,14,0,0,0,0,0
    db 0,6,14,6,6,14,14,14,14,14,14,14,0,0,0,0
    db 0,0,6,14,14,14,14,14,14,14,0,0,0,0,0,0
    db 0,0,0,14,14,14,14,14,14,0,0,0,0,0,0,0
    db 0,0,4,4,1,4,4,4,1,4,4,0,0,0,0,0
    db 0,4,4,4,1,4,4,4,1,4,4,4,0,0,0,0
    db 0,4,4,4,1,1,1,1,1,4,4,4,0,0,0,0
    db 0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0
    db 0,0,6,6,6,0,0,6,6,6,0,0,0,0,0,0
    db 0,6,6,6,0,0,0,0,6,6,6,0,0,0,0,0
    db 0,6,6,0,0,0,0,0,0,6,6,0,0,0,0,0
    db 0,0,0,0,6,6,0,6,6,0,0,0,0,0,0,0
    db 0,0,0,6,6,0,0,0,6,6,0,0,0,0,0,0

sprite_mario_jump:
    db 0,0,0,4,4,4,4,4,4,4,0,0,0,0,0,0
    db 0,0,4,4,4,4,4,4,4,4,4,4,0,0,0,0
    db 0,0,6,6,6,14,14,14,14,14,0,0,0,0,0,0
    db 0,6,14,6,14,14,14,14,14,14,14,0,0,0,0,0
    db 0,6,14,6,6,14,14,14,14,14,14,14,0,0,0,0
    db 0,0,6,14,14,14,14,14,14,14,0,0,0,0,0,0
    db 0,0,0,14,14,14,14,14,14,0,0,0,0,0,0,0
    db 0,0,4,4,1,4,4,4,1,4,4,0,0,0,0,0
    db 0,4,4,4,1,4,4,4,1,4,4,4,0,0,0,0
    db 0,4,4,4,1,1,1,1,1,4,4,4,0,0,0,0
    db 0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0
    db 0,0,6,6,6,6,6,6,6,6,0,0,0,0,0,0
    db 0,6,6,6,0,0,0,0,6,6,6,0,0,0,0,0
    db 0,6,6,0,0,0,0,0,0,6,6,0,0,0,0,0
    db 0,0,6,6,0,0,0,0,6,6,0,0,0,0,0,0
    db 0,0,0,6,6,0,0,0,6,6,0,0,0,0,0,0

sprite_goomba:
    db 0,0,0,0,0,6,6,6,6,0,0,0,0,0,0,0
    db 0,0,0,6,6,6,6,6,6,6,6,0,0,0,0,0
    db 0,0,6,6,6,6,6,6,6,6,6,6,0,0,0,0
    db 0,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0
    db 0,6,6,4,4,6,6,6,6,4,4,6,6,0,0,0
    db 0,6,4,15,4,6,6,6,6,4,15,4,6,0,0,0
    db 0,6,4,4,4,6,6,6,6,4,4,4,6,0,0,0
    db 0,0,6,6,6,6,6,6,6,6,6,6,0,0,0,0
    db 0,0,0,6,6,6,6,6,6,6,6,0,0,0,0,0
    db 0,0,6,6,6,6,6,6,6,6,6,6,0,0,0,0
    db 0,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0
    db 0,6,6,6,6,6,6,6,6,6,6,6,6,0,0,0
    db 0,0,6,6,6,6,6,6,6,6,6,6,0,0,0,0
    db 0,0,4,4,4,0,0,0,0,0,4,4,4,0,0,0
    db 0,4,4,4,0,0,0,0,0,0,0,4,4,4,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

sprite_goomba_flat:
    times 5 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    times 3 db 0,0,0,6,6,6,6,6,6,6,6,6,0,0,0,0
    times 2 db 0,0,6,6,6,6,6,6,6,6,6,6,6,0,0,0
    times 6 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

sprite_koopa:
    times 16 db 0,0,0,2,2,2,2,2,2,2,2,0,0,0,0,0
sprite_shell:
    times 16 db 0,0,0,2,2,2,2,2,2,2,2,0,0,0,0,0
sprite_mushroom:
    db 0,0,0,0,4,4,4,4,4,4,4,4,0,0,0,0
    db 0,0,0,4,4,4,4,4,4,4,4,4,4,0,0,0
    db 0,0,4,4,15,15,4,4,4,15,15,4,4,0,0,0
    db 0,0,4,4,15,15,4,4,4,15,15,4,4,0,0,0
    db 0,0,4,4,4,4,4,4,4,4,4,4,4,0,0,0
    db 0,0,0,4,4,4,4,4,4,4,4,4,0,0,0,0
    times 10 db 0,0,0,15,15,15,15,15,15,15,15,15,0,0,0,0
sprite_coin:
    db 0,0,0,0,0,14,14,14,14,14,0,0,0,0,0,0
    db 0,0,0,0,14,14,14,14,14,14,14,0,0,0,0,0
    db 0,0,0,14,14,14,14,14,14,14,14,14,0,0,0,0
    db 0,0,14,14,14,14,14,14,14,14,14,14,14,0,0,0
    db 0,0,14,14,14,14,14,14,14,14,14,14,14,0,0,0
    db 0,0,0,14,14,14,14,14,14,14,14,14,0,0,0,0
    db 0,0,0,0,14,14,14,14,14,14,14,0,0,0,0,0
    times 9 db 0,0,0,0,0,14,14,14,14,14,0,0,0,0,0,0
sprite_super_stand:
    times 2 db 0,0,0,4,4,4,4,4,4,4,0,0,0,0,0,0
    times 2 db 0,0,4,4,4,4,4,4,4,4,4,4,0,0,0,0
    times 2 db 0,6,6,6,14,14,14,14,14,14,14,0,0,0,0,0
    times 2 db 0,6,14,6,14,14,14,14,14,14,14,14,0,0,0,0
    times 2 db 0,0,6,14,14,14,14,14,14,14,0,0,0,0,0,0
    times 2 db 0,0,4,4,1,4,4,4,1,4,4,0,0,0,0,0
    times 2 db 0,4,4,4,1,4,4,4,1,4,4,4,0,0,0,0
    times 2 db 0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0
    times 2 db 0,0,6,6,6,0,0,6,6,6,0,0,0,0,0,0
    times 2 db 0,0,6,6,0,0,0,0,6,6,0,0,0,0,0,0
