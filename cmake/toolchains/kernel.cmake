set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_CROSSCOMPILING TRUE)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Default to system x86_64 compilers unless overridden by environment
if(NOT CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER gcc)
endif()

if(NOT CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_COMPILER g++)
endif()

if(NOT CMAKE_ASM_COMPILER)
    set(CMAKE_ASM_COMPILER as)
endif()
