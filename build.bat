@echo off
cd /d "%~dp0src"
"C:\Users\khan\AppData\Local\bin\NASM\nasm.exe" -f bin mario.asm -o ..\MARIO.COM
if errorlevel 1 (echo BUILD FAILED) else (echo BUILD OK)
cd /d "%~dp0"