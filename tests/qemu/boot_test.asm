; minimal MBR test to verify QEMU boot pipeline and serial logging

[bits 16]
[org 0x7c00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    mov dx, 0x3F9
    mov al, 0x00
    out dx, al

    mov dx, 0x3FB
    mov al, 0x80
    out dx, al

    mov dx, 0x3F8
    mov al, 0x01
    out dx, al

    mov dx, 0x3F9
    mov al, 0x00
    out dx, al

    mov dx, 0x3FB
    mov al, 0x03
    out dx, al

    mov si, test_message

send_char:
    lodsb
    test al, al
    jz test_complete
    mov dx, 0x3F8
    out dx, al
    jmp send_char

test_complete:
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax

halt_state:
    hlt
    jmp halt_state

test_message:
    db "Lumina Phase 0 QEMU Boot Verification: OK", 0x0D, 0x0A, 0x00

times 510 - ($ - $$) db 0
dw 0xAA55
