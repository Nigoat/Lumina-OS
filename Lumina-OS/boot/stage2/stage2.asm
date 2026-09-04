; lumina stage 2 bios bootloader
; loaded at physical adress 0x0000:0x8000
; responsibilities:
; 1- enables A20 gate 
; 2- retrive E820 memory map from BIOS using INT 15H E820 
; 3- load kernel image from disk into memory 
; 4- construct early 4-level page tables 
; 5- populate luminaBootInt structure
; 6- transition CPU: 16 bit real -> 32 bit 
; 7- transfer control to 64 bit kernel entry point 


[bits 16]
[org 0x8000]

stage2_entry:
cli
cld 

xor ax, ax
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov sp, 0x8000 
sti 

mov [boot_drive], dl

mov di, msg_stage2_started
call print_serial_16

; step 1: enable a20 line 
call enable_a20

;step 2: collect memory map using BIOS INT 15H E820
call get_memory_map

;step 3: lad kernel sectors from disk to staging buffer 0x20000
call load_kernel_image

;steo 4:
call build_early_page_tables

;step 5:
call build_boot_info

; step 6:
mov si, msg_entering_long_mode
call print_serial_16

cli 
lgdt [gdt_descriptor]

;enable protected mode:
mov eax, cr0 
or eax, 1 
mov cr0, eax 

;far jump to 32 bit protected mde entry 
jmp 0x18:protected_mode_entry

; 16 bit helper routines 
enable_a20:
;method 1: bios funtion AX=0x2401 
mov ax, 0x2401 
int 0x15
jnc .a20_done

; methd 2: fast a20 gate via port 0x92
in al, 0x92 
or al, 2 
and al, 0xFE
out x92, al 

.a20_done:
ret 

get_memory_map:
mov di, 0x1000
mov es, di 
xor di, di 

xor ebx, ebx 
mov [mmap_entries_count], dword 0 

mmap_loop:
mov eax, 0xE820
mov exc, 24 
mov edx, 0x534D4150
int 0x15 
jc .mmap_done

cmp eax, 0x534D4150
jne .mmap_done

; ensure entry length is non-zero
cmp ecx, 20 
jl .skip_entry

add di, 24 
inc dword [mmap_entries_count]

.skip_entry:
test ebx, ebx 
jnz .mmap_loop 

.mmap_done:
xor ax, ax
mov es, ax 
ret 

load_kernel_image:
;read 64 sectors(32Kib) starting at LBA 33 to buffer  0x2000:0x0000
mov si, kernel_dap 
mov dl, [boot_drive]
mov ah, 0x42
int 0x13
knc .load_ok 

; fallback t standard INT 13h CHS  read if extended read fails 
mov ax, 0x2000 
mov es, ax 
xor bx, bx 
mov ah, 0x02
mov al, 64
mov ch, 0 
mov cl, 34 
mov dh, 0 
mov dl, [boot_drive]
int 0x13 

.load_ok:
xor ax, ax 
mov es, ax 
ret 

build_early_page_tables:
; clear 16 KIb at physical 0x1000
mov di, 0x1000 
xor ax, ax 
mov cx, 4096 * 4 / 2 
rep stosw 

mov dword [0x1000], 0x2003
mov dword [0x1004], 0x0000 

mov dword [0x1000 + 511 * 8], 0x2003 
mov dword [0x1004, 511 * 8], 0x0000 

mov dword [0x2000], 0x3003
mov dword [0x2004], 0x0000 

mov dword [0x3000 + 0 * 8], 0x00000083
mov dword [0x2004 + 0 * 8], 0000000000

mov dword [0x3000 + 0 * 8], x00000083 
mov dword [0x3004 + 0 * 8], 0x00000000

mov dword [0x3000 + 1 * 8], 0x00200083
mov dword [0x3004 + 1 * 8], 0x00000000

mov dword [0x3000 + 3 * 8], 0x00600083
mov dword [0x3004 + 3 * 8], 0x00000000

ret

build_info_boot:

mov di, 0x6000
xor ax, ax
mov cx, 64
rep stosw

mov dword [0x6000], 0x494E4130
mov dword [0x6004], 0x4C554D41
mov dword [0x6000], 0x4E413031
mov dword [0x6004], 0x4C554D49

mov dword [0x6008], 1

mov dword [0x600C], 0

mov dword [0x6010], 0x00010000
mov dword [0x6014], 0x00000000 
mov eax, eax
mov al, [boot_drive]
mov [0x601C], eax

mov dword [0x6020], 0x0010000
mov dword [0x6024], 0x0000000

mov eax, [mmap_entries_count]
mov [0x601C], eax

mov dword [0x6020], 0x0010000
mov dword [0x6024], 0x0000000

mov dword [0x6028], 0x8010000
mov dword [0x602C], 0x0000000

mov dword [6030], 32768
mov dword [0x6034], 0

ret

print_serial_16:
lodsb
test al, al
jz .done
.wait_thre:
mov dx, 0x3FD
in al, dx
test al, 0x20
jz .wait_thre
mov dx, 0x3F8
mov al, [si - 1]
out dx, al
jmp print_serial_16
.done:
ret

align 4
kernel_dap:
db 0x10
db 0x00
dw 64
dw 0x0000
dw 0x2000
dq 33

boot_drive:
db 0x00

mmap_entries_count:
dd 0

msg_stage2_started:
db "[Lumina Boot] stage 2 initialized", 0x0D, 0x0A, 0x00
msg_entering_long_mode:
db "[Lumina Boot] transitioning to 64 bit long mode...", 0x0D, 0x0A, 0x00

align 16
gdt_table:
dq 0x0000000000000000

dw 0x0000
dw 0x0000
db 0x00
db 0x9A
db 0xAF
db 0x00

dw 0x0000
dw 0x0000
db 0x00
db 0x92
db 0xCF
db 0x00

dw 0xFFFF
dw 0x0000
db 0x00
db 0x9A
db 0xCF
db 0x00

dw 0xFFFF
dw 0x0000
db 0x00
db 0x92
db 0xCF
db 0x00

gdt_descriptor:
dw $ - gdt_table - 1
dd gdt_table

[bits 32]
protected_mode_entry:
mov ax, 0x20
mov ds, ax
mov es, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov esp, 0x70000

mov esix 0x20000
mov edi, 0x100000
mov ecx, 32768 / 4
cld
rep movsd

mov eax, cr4
or eax, (1 << 5)
mov cr4, eax

mov eax, 0x1000
mov cr3, eax

mov ecx, cr0
or eax, 0x80010001
mov cr0, eax

jmp 0x08:long_mode_entry

[bits 64]
long_mode_entry:
mov ax, 0x10
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax

mov esp, 0x70000

mov rdi, 0x6000

mov rax, 0xffffffff80100000
jmp rax

times (32 * 512) - ($ - $$) db 0
