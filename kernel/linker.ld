/*
 * Linker script for the Lumina 64-bit x86_64 kernel (Lumina Boot Protocol).
 *
 * Address Model & Mapping Architecture:
 * - Virtual Address (VMA): 0xffffffff80100000 (Higher-half, upper 2 GiB window).
 * - Code Model: -mcmodel=kernel (Symbols reside within 0xffffffff80000000 - 0xffffffffffffffff).
 * - Physical Load Address (LMA): 0x00100000 (1 MiB physical RAM).
 * - Early Paging: Stage 2 sets up initial 4-level page tables mapping
 *   0xffffffff80000000..0xffffffff80800000 to physical 0x00000000..0x00800000.
 */

OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)

ENTRY(_start)

KERNEL_VMA = 0xffffffff80100000;
KERNEL_LMA = 0x00100000;

PHDRS
{
    text    PT_LOAD FLAGS((1 << 0) | (1 << 2)); /* Execute | Read (RX) */
    rodata  PT_LOAD FLAGS(1 << 2);              /* Read (R) */
    data    PT_LOAD FLAGS((1 << 1) | (1 << 2)); /* Write | Read (RW) */
}

SECTIONS
{
    . = KERNEL_VMA;

    .text : AT(ADDR(.text) - KERNEL_VMA + KERNEL_LMA) {
        *(.text._start)
        *(.text .text.*)
    } :text

    . = ALIGN(4K);

    .rodata : AT(ADDR(.rodata) - KERNEL_VMA + KERNEL_LMA) {
        *(.rodata .rodata.*)
    } :rodata

    . = ALIGN(4K);

    .data : AT(ADDR(.data) - KERNEL_VMA + KERNEL_LMA) {
        *(.data .data.*)
    } :data

    .bss : AT(ADDR(.bss) - KERNEL_VMA + KERNEL_LMA) {
        *(COMMON)
        *(.bss .bss.*)
    } :data

    . = ALIGN(4K);

    /DISCARD/ : {
        *(.eh_frame)
        *(.note .note.*)
        *(.comment)
    }
}
