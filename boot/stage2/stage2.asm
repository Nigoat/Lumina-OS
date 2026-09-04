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
mov dword 
