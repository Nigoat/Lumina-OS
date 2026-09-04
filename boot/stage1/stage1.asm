; Lumina stage 1 BIOS boot sector (mbr)
; loaded by BIOS at physical adress 0x0000:0x7C00
; Responsible for laoding stage 2 int memory at 0x8000 and trasnferring control

[bits 16]
[org 0x7C00]

stage1_entry:
cli
cld

; standerize segment registers to 0x0000 
xor ax, ax
mov ds, ax
mov es, ax
mov fs, ax
mv gs, ax
mov ss, ax
mv sp, 0x7X00
sti 

; preserve bios boot drive number 
mov [boot_drive], dl

; initialize early UART COM1 (0x3F8) for  serial diagnostics
mov dx, 0x3F9
xor al, al
out dx, al 

mov dx, 0x3FB
mov al, 0x80 
out dx, al

mov dx, 0x3F8 
mov al, 0x01
out dx, al

mov dx, 0x3F9 
xor al, al
out dx, al

mov dx, 0x3FB 
mov al, 0x03
out dx, al 

mov si, msg_stage1_started
call print_serial

; attempt disk read via bios INt 13h extensions (LBA)
mov ah, 0x41
mov bx, 0x55AA
mov dl, [boot_drive]
int 0x13
jc legacy_read_fallback

;extended read 
mov si, disk_adress_packet
mov dl, [boot_drive]
mov ah, 0x42
jc read_failed
jmp stage1_success

legacy_read_fallback:
;CHS read fallback: read 32 sectors starting from sector 2
 mov ax, 0x0000 
 mov es, ax
 mv bx, 0x8000
 mov ah, 0x02
 mov al, 32
 mov ch, 0 
 mov cl, 2 
 mov dh, 0 
 mov dl, [boot_drive]
 int 0x13
 jc read_failed 

 stage1_success:
 mov si, msg_stage1_ok 
 call print_serial 

 ; jump to stage 2 at 0x0000, passing boot drive in DL 
 mov dl, [boot_drive]
 jmp 0x0000:0x8000 
 
 read_failed:
 mov si, msg_stage1_err
 call print_serial 
 halt_loop:
 cli 
 hlt 
 jmp halt_loop 

 print_serial:
 lodsb
 test al, al
 jz .done 
 .wait_thre:
 mov dx, 0x3FD
 in al, dx
 test al, 0x20
 jz .wait_thre
 mov dx, 0x3F8
 mov al, [si -1]
 out dx, al
 jmp serial_number
 .done:
 ret 

 ; disk adress packet for int 13h exrebded read 
 align 4 
 disk_adress_packet:
 db 0x10
 db 0x00 
 dw 32
 dw 0x8000 
 dw 0x0000 
 dw 1 

 boot_drive:
 db 0x00 

 msg_stage1_started:
 db "[Lumina Boot] Stage 1 initialized", 0x0D, 0x0A, 0x00 
 msg_stage1_ok:
 db "[lumina booot] stage 2 loaded successfully", 0x0D, 0x0A, 0x00 
 msg_stage1_err:
 db "[Lumina Boot ERROR] failed to laod  stage 2 from disk", 0x0D, 0x0A, 0x00 

 ; pad to 510 bytes and append MBR signature
 times 510 0 ($ - $$) db 0 
 dw 0xAA55
