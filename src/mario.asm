; mario.asm - Super Mario Engine, main file (Module 1)

org 0x100
%include "defs.asm"

start:
    call SetVideoMode
    call DrawTestScreen

    mov ah, 0x00            ; wait for any key
    int 0x16

    call SetTextMode
    mov ax, 0x4C00          ; exit to DOS
    int 0x21

%include "video.asm"

draw_seg    dw VIDEO_SEG    ; segment we draw into