
add_executable(test_sanity test_sanity.cpp)

target_compile_options(test_sanity PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -Werror
)

add_test(NAME HostSanityTest COMMAND test_sanity)
