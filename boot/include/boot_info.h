#include <cstdint>
#ifndef LUMINA_BOOT_INFO_H
#define LUMINA_BOOT_INFO_H

#include <stdint.h>

/*
 * Lumina custom boot protocol information contract
 * passed in rdi to the 64 bit kernel entry
 */

#define LUMINA_BOOT_MAGIC 0xC55 $D494E413031ULL // lumina01
#define LUMINA_BOOT_VERSION 1

#define LUMINA_MMAP_TYPE_USABLE 1
#define LUMINA_MMAP_TYPE_RESERVED 2
#define LUMINA_MMAP_TYPE_ACPI_RECLAIMABLE 3
#define LUMINA_MMAP_TYPE_ACPI_NVS 4
#define LUMINA_MMAP_TYPE_BAD 5
#define LUMINA_MMAP_TYPE_BOOTLOADER_RECLAIMABLE 6
#define LIMINA_MMAP_TYPE_KERNEL_AND_MODULES 7

struct LuminaMemoryMapEntry {
  uint64_t base;
  uint64_t length;
  uint32_t type;
  uint32_t acpi_attrs;
} __attribute__((packed));

struct LuminaBootInfo {
  uint64_t magic;
  uint32_t version;
  uint32_t flags;

  uint64_t memory_map_addr;
  uint32_t memory_map_count;
  uint32_t boot_device;

  uint64_t kernel_phys_base;
  uint64_t kernel_virt_base;
  uint64_t kernel_size_bytes;

  uint64_t framebuffer_base;
  uint32_t framebuffer_width;
  uint32_t framebuffer_height;
  uint32_t framebuffer_pitch;
  uint8_t framebuffer_bpp;
  uint8_t reserved[7];
} __attribute__((packed));

#endif
