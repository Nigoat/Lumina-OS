
# kernel conf 
set(KERNEL_SOURCES
    arch/x86_64/entry.cpp
)

add_library(lumina_kernel_freestanding INTERFACE)

target_compile_features(lumina_kernel_freestanding INTERFACE cxx_std_20)

target_compile_options(lumina_kernel_freestanding INTERFACE
    -ffreestanding
    -fno-exceptions
    -fno-rtti
    -fno-stack-protector
    -fno-pic
    -fno-pie
    -mno-red-zone
    -mcmodel=kernel
    -mno-mmx
    -mno-sse
    -mno-sse2
    -Wall
    -Wextra
    -Wpedantic
    -Werror
    -O2
)

target_link_options(lumina_kernel_freestanding INTERFACE
    -nostdlib
    -static
    -no-pie
    -Wl,--build-id=none
    -Wl,-z,max-page-size=0x1000
    -T ${CMAKE_CURRENT_SOURCE_DIR}/linker.ld
)

target_include_directories(lumina_kernel_freestanding INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/boot/include
)

# Build the 64-bit kernel ELF executable
add_executable(lumina_kernel ${KERNEL_SOURCES})
target_link_libraries(lumina_kernel PRIVATE lumina_kernel_freestanding)

set(KERNEL_BIN "${CMAKE_CURRENT_BINARY_DIR}/kernel.bin")
find_program(OBJCOPY_EXECUTABLE objcopy)

if(OBJCOPY_EXECUTABLE)
    add_custom_command(
        OUTPUT "${KERNEL_BIN}"
        COMMAND "${OBJCOPY_EXECUTABLE}" -O binary "$<TARGET_FILE:lumina_kernel>" "${KERNEL_BIN}"
        DEPENDS lumina_kernel
        COMMENT "Extracting raw 64-bit kernel binary"
    )
    add_custom_target(generate_kernel_bin ALL DEPENDS "${KERNEL_BIN}")
endif()

add_custom_target(kernel_target ALL DEPENDS lumina_kernel)
