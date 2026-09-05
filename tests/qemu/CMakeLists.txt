# QEMU Integration and Boot Test Harness

find_program(NASM_EXECUTABLE nasm)
find_program(QEMU_EXECUTABLE qemu-system-x86_64)

if(NASM_EXECUTABLE AND QEMU_EXECUTABLE)
    set(BOOT_SANITY_BIN "${CMAKE_CURRENT_BINARY_DIR}/boot_sanity.bin")

    add_custom_command(
        OUTPUT "${BOOT_SANITY_BIN}"
        COMMAND "${NASM_EXECUTABLE}" -f bin "${CMAKE_CURRENT_SOURCE_DIR}/boot_test.asm" -o "${BOOT_SANITY_BIN}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/boot_test.asm"
        COMMENT "Assembling Phase 0 toolchain sanity boot image"
    )

    add_custom_target(generate_boot_sanity_image ALL DEPENDS "${BOOT_SANITY_BIN}")

    set(QEMU_BASE_TEST_FLAGS
        -display none
        -serial stdio
        -no-reboot
        -device isa-debug-exit,iobase=0xf4,iosize=0x04
    )

    add_test(
        NAME QEMUToolchainSanityTest
        COMMAND "${QEMU_EXECUTABLE}"
            -drive "format=raw,file=${BOOT_SANITY_BIN}"
            ${QEMU_BASE_TEST_FLAGS}
    )

    set_tests_properties(QEMUToolchainSanityTest PROPERTIES
        TIMEOUT 10
        PASS_REGULAR_EXPRESSION "Lumina Phase 0 QEMU Boot Verification: OK"
    )

    set(LUMINA_DISK_IMG "${CMAKE_BINARY_DIR}/lumina_disk.img")

    add_test(
        NAME LuminaBootloaderKernelTest
        COMMAND "${QEMU_EXECUTABLE}"
            -drive "format=raw,file=${LUMINA_DISK_IMG}"
            ${QEMU_BASE_TEST_FLAGS}
    )

    set_tests_properties(LuminaBootloaderKernelTest PROPERTIES
        TIMEOUT 10
        PASS_REGULAR_EXPRESSION "Lumina custom bootloader -> 64-bit kernel: PASS"
    )
endif()
