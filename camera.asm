; ============================================================
; camera.asm - Module 6: Camera and horizontal scrolling
; Requires shared mario_x (8.8 world coordinate) and camera_x.
; camera_x is an integer pixel coordinate (word).
; ============================================================

CAMERA_FOLLOW_X equ 160
CAMERA_MAX_X    equ 640
CAMERA_LEFT_X   equ 0

; ------------------------------------------------------------
; UpdateCamera
; Purpose: follow Mario after screen_x passes 160; clamp 0..640;
;          never scroll left. Mario is stopped at world x = camera_x
;          when the left edge would otherwise be crossed.
; Inputs: none (reads mario_x and camera_x).
; Outputs: camera_x updated; screen_x updated.
; Registers changed: none.
; ------------------------------------------------------------
UpdateCamera:
    push ax
    push bx
    push dx

    mov ax, [mario_x]
    mov cl, 8
    shr ax, cl                  ; integer world x
    sub ax, [camera_x]          ; screen_x
    cmp ax, CAMERA_FOLLOW_X
    jle .clamp
    mov ax, [mario_x]
    mov cl, 8
    shr ax, cl
    sub ax, CAMERA_FOLLOW_X
    cmp ax, CAMERA_MAX_X
    jbe .store
    mov ax, CAMERA_MAX_X
.store:
    cmp ax, [camera_x]
    jbe .clamp                  ; camera never moves left
    mov [camera_x], ax
.clamp:
    cmp word [camera_x], CAMERA_LEFT_X
    jae .max_check
    mov word [camera_x], CAMERA_LEFT_X
.max_check:
    cmp word [camera_x], CAMERA_MAX_X
    jbe .screen
    mov word [camera_x], CAMERA_MAX_X
.screen:
    mov ax, [mario_x]
    mov cl, 8
    shr ax, cl
    sub ax, [camera_x]
    mov [mario_screen_x], ax

    ; Do not allow Mario to move to the left of the visible screen.
    cmp word [mario_screen_x], 0
    jge .done
    mov word [mario_screen_x], 0
    mov ax, [camera_x]
    mov cl, 8
    shl ax, cl
    mov [mario_x], ax
.done:
    pop dx
    pop bx
    pop ax
    ret

; ------------------------------------------------------------
; WorldToScreenX
; Purpose: convert world pixel X to screen X.
; Inputs: AX = world X.
; Outputs: AX = screen X.
; Registers changed: none except AX output.
; ------------------------------------------------------------
WorldToScreenX:
    sub ax, [camera_x]
    ret

; ------------------------------------------------------------
; CameraReset
; Purpose: reset camera at new life/new game.
; Inputs: none. Outputs: camera_x=0. Registers changed: none.
; ------------------------------------------------------------
CameraReset:
    push ax
    mov word [camera_x], 0
    mov word [mario_screen_x], 0
    pop ax
    ret

camera_x       dw 0
mario_screen_x dw 0
