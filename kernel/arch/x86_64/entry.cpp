#include <stddef.h>
#include <stdint.h>
#include "../../boot/include/boot_info.h"

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline uint8_t inb(uint16_t port) {
    uint8_t ret;
    __asm__ volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

static inline void outw(uint16_t port, uint16_t val) {
    __asm__ volatile("outw %0, %1" : : "a"(val), "Nd"(port));
}

static void serial_init() {
    outb(0x3F9, 0x00);
    outb(0x3FB, 0x80);
    outb(0x3F8, 0x01);
    outb(0x3F9, 0x00);
    outb(0x3FB, 0x03);
}

static void serial_write_char(char c) {
    while ((inb(0x3FD) & 0x20) == 0) {
    }
    outb(0x3F8, (uint8_t)c);
}

static void serial_write_string(const char* str) {
    for (size_t i = 0; str[i] != '\0'; ++i) {
        if (str[i] == '\n') {
            serial_write_char('\r');
        }
        serial_write_char(str[i]);
    }
}

extern "C" __attribute__((section(".text._start"))) void _start(const struct LuminaBootInfo* boot_info) {
    serial_init();

    if (boot_info != nullptr && boot_info->magic == LUMINA_BOOT_MAGIC && boot_info->version == LUMINA_BOOT_VERSION) {
        serial_write_string("[Lumina Kernel] Boot protocol validated successfully.\n");
        serial_write_string("Lumina custom bootloader -> 64-bit kernel: PASS\n");
    } else {
        serial_write_string("[Lumina Kernel] Invalid boot info magic!\n");
    }

    outb(0xF4, 0x10);

    outw(0x604, 0x2000);

    /* Halt CPU */
    for (;;) {
        __asm__ volatile("cli; hlt");
    }
}
