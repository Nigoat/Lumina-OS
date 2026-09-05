cmake_minimum_required(VERSION 3.25)
project(LuminaOS LANGUAGES C CXX ASM)

option(BUILD_KERNEL "Build the freestanding kernel target" ON)
option(BUILD_USER "Build user-space targets" ON)
option(BUILD_TOOLS "Build host development tools" ON)
option(BUILD_TESTS "Build host and integration tests" ON)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)


set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(BUILD_TOOLS)
    add_subdirectory(tools)
endif()

if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

add_subdirectory(libraries)
add_subdirectory(boot)

if(BUILD_KERNEL)
    add_subdirectory(kernel)
endif()

if(BUILD_USER)
    add_subdirectory(user)
endif()
