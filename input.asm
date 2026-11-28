; ============================================================
; input.asm - Module 7: Keyboard interrupt handler (INT 09h)
; Installs a handler which records make/break scan codes.
; E0 prefix is ignored; arrow scan codes are processed normally.
; ============================================================

; ------------------------------------------------------------
; InstallKeyboard
; Purpose: save old INT 09h vector and install KeyboardISR.
; Inputs/outputs: none.
; Registers changed: none.
; ------------------------------------------------------------
InstallKeyboard:
    push ax
    push dx
    push ds
    mov ax, 0x3509
    int 0x21
    mov [old_kbd_off], bx
    mov [old_kbd_seg], es
    push cs
    pop ds
    mov dx, KeyboardISR
    mov ax, 0x2509
    int 0x21
    pop ds
    pop dx
    pop ax
    ret

; ------------------------------------------------------------
; RestoreKeyboard
; Purpose: restore original INT 09h vector.
; Inputs/outputs: none.
; Registers changed: none.
; ------------------------------------------------------------
RestoreKeyboard:
    push ax
    push dx
    push ds
    mov dx, [old_kbd_off]
    mov ax, [old_kbd_seg]
    mov ds, ax
    mov ax, 0x2509
    int 0x21
    pop ds
    pop dx
    pop ax
    ret

; ------------------------------------------------------------
; KeyboardISR
; Purpose: read scan code, update 128-byte key_state, acknowledge PIC.
; Inputs: hardware scan code from port 60h.
; Outputs: key_state[scan_code] = 1 on press, 0 on release.
; Registers changed: AX, BX, DS (saved/restored).
; ------------------------------------------------------------
KeyboardISR:
    push ax
    push bx
    push ds
    push cs
    pop ds

    in al, 0x60
    cmp al, 0xE0
    je .ack
    mov bl, al
    and bl, 0x7F
    cmp bl, 127
    ja .ack
    xor bh, bh
    test al, 0x80
    jnz .released
    mov byte [key_state+bx], 1
    jmp .ack
.released:
    mov byte [key_state+bx], 0
.ack:
    mov al, 0x20
    out 0x20, al
    pop ds
    pop bx
    pop ax
    iret

; ------------------------------------------------------------
; ClearKeys
; Purpose: clear all held-key flags.
; Inputs/outputs: none.
; Registers changed: none.
; ------------------------------------------------------------
ClearKeys:
    push ax
    push cx
    push di
    push es
    push cs
    pop es
    xor ax, ax
    mov di, key_state
    mov cx, 128
    cld
    rep stosb
    pop es
    pop di
    pop cx
    pop ax
    ret

; Required scan codes from Appendix A.3:
; Left=4Bh Right=4Dh Up=48h Down=50h Space=39h LShift=2Ah
; P=19h Enter=1Ch Esc=01h
old_kbd_off dw 0
old_kbd_seg dw 0
key_state times 128 db 0
