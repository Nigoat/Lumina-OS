# Custom Lumina BIOS Bootloader Build Configuration

find_program(NASM_EXECUTABLE nasm)

if(NASM_EXECUTABLE)
    set(STAGE1_BIN "${CMAKE_CURRENT_BINARY_DIR}/stage1.bin")
    set(STAGE2_BIN "${CMAKE_CURRENT_BINARY_DIR}/stage2.bin")
    set(LUMINA_DISK_IMG "${CMAKE_BINARY_DIR}/lumina_disk.img")

    # Assemble Stage 1 MBR Boot Sector (512 bytes)
    add_custom_command(
        OUTPUT "${STAGE1_BIN}"
        COMMAND "${NASM_EXECUTABLE}" -f bin "${CMAKE_CURRENT_SOURCE_DIR}/stage1/stage1.asm" -o "${STAGE1_BIN}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/stage1/stage1.asm"
        COMMENT "Assembling Lumina Stage 1 BIOS boot sector"
    )

    # Assemble Stage 2 Bootloader (16 KiB / 32 sectors)
    add_custom_command(
        OUTPUT "${STAGE2_BIN}"
        COMMAND "${NASM_EXECUTABLE}" -f bin "${CMAKE_CURRENT_SOURCE_DIR}/stage2/stage2.asm" -o "${STAGE2_BIN}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/stage2/stage2.asm"
        COMMENT "Assembling Lumina Stage 2 BIOS bootloader"
    )

    # Disk Image Generation: Stitch Stage 1 + Stage 2 + Kernel Binary
    set(KERNEL_BIN "${CMAKE_BINARY_DIR}/kernel/kernel.bin")

    # Pad/Stitch into full raw boot disk image
    add_custom_command(
        OUTPUT "${LUMINA_DISK_IMG}"
        COMMAND ${CMAKE_COMMAND} -E cat "${STAGE1_BIN}" "${STAGE2_BIN}" "${KERNEL_BIN}" > "${LUMINA_DISK_IMG}"
        DEPENDS "${STAGE1_BIN}" "${STAGE2_BIN}" "${KERNEL_BIN}" generate_kernel_bin
        COMMENT "Building Lumina raw boot disk image (lumina_disk.img)"
    )

    add_custom_target(lumina_disk ALL DEPENDS "${LUMINA_DISK_IMG}")
    add_custom_target(bootloader ALL DEPENDS "${STAGE1_BIN}" "${STAGE2_BIN}")
endif()
