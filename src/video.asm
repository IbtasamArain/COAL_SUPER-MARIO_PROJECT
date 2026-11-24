; video.asm - Module 2: video mode, PutPixel, FillRect, test screen

; Name     : SetVideoMode
; Purpose  : switch to VGA mode 13h (320x200, 256 colours)
; Inputs   : none
; Outputs  : none
; Changes  : none (ax saved)
SetVideoMode:
    push ax
    mov ax, 0x0013
    int 0x10
    pop ax
    ret

; Name     : SetTextMode
; Purpose  : switch back to 80x25 text mode
; Inputs   : none
; Outputs  : none
; Changes  : none (ax saved)
SetTextMode:
    push ax
    mov ax, 0x0003
    int 0x10
    pop ax
    ret

; Name     : PutPixel
; Purpose  : draw one pixel at (x, y)
; Inputs   : stack: push x, push y, push colour (in this order)
; Outputs  : none
; Changes  : none (all saved)
; Offset   : y*320 + x = y*256 + y*64 + x
PutPixel:
    push bp
    mov bp, sp
    push ax
    push bx
    push di
    push es

    mov ax, [draw_seg]
    mov es, ax
    mov bx, [bp+6]          ; y
    mov di, bx
    shl di, 8               ; y * 256
    shl bx, 6               ; y * 64
    add di, bx
    add di, [bp+8]          ; + x
    mov al, [bp+4]          ; colour
    mov [es:di], al

    pop es
    pop di
    pop bx
    pop ax
    pop bp
    ret 6

; Name     : FillRect
; Purpose  : fill a rectangle with one colour
; Inputs   : stack: push x, y, width, height, colour (in this order)
; Outputs  : none
; Changes  : none (all saved)
FillRect:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    mov ax, [draw_seg]
    mov es, ax
    mov bx, [bp+10]         ; y
    mov di, bx
    shl di, 8
    shl bx, 6
    add di, bx
    add di, [bp+12]         ; + x = start offset
    mov al, [bp+4]          ; colour
    mov dx, [bp+6]          ; rows left
    cmp dx, 0
    je .done
    cld
.row:
    mov cx, [bp+8]          ; width
    push di
    rep stosb
    pop di
    add di, SCREEN_W        ; next row
    dec dx
    jnz .row
.done:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10

; Name     : DrawTestScreen
; Purpose  : show 16 colour bars (20 px wide each) and two test pixels
; Inputs   : none
; Outputs  : none
; Changes  : none (all saved)
DrawTestScreen:
    push ax
    push bx
    push cx

    xor bx, bx              ; x position
    xor cx, cx              ; colour number
.next:
    push bx                 ; x
    xor ax, ax
    push ax                 ; y = 0
    mov ax, 20
    push ax                 ; width
    mov ax, SCREEN_H
    push ax                 ; height
    push cx                 ; colour
    call FillRect
    add bx, 20
    inc cx
    cmp cx, 16
    jne .next

    mov ax, 10
    push ax                 ; x
    push ax                 ; y
    mov ax, COL_WHITE
    push ax
    call PutPixel           ; white pixel on the black bar

    mov ax, 309
    push ax                 ; x
    mov ax, 10
    push ax                 ; y
    mov ax, COL_BLACK
    push ax
    call PutPixel           ; black pixel on the white bar

    pop cx
    pop bx
    pop ax
    ret