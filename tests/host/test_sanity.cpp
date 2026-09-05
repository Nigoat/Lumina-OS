#include <cstdint>
#include <cstddef>
#include <iostream>

template <typename T>
constexpr bool is_aligned(T value, size_t alignment) {
    return (static_cast<uintptr_t>(value) & (alignment - 1)) == 0;
}

template <typename T>
constexpr T align_up(T value, size_t alignment) {
    return static_cast<T>((static_cast<uintptr_t>(value) + (alignment - 1)) & ~(alignment - 1));
}

template <typename T>
constexpr T align_down(T value, size_t alignment) {
    return static_cast<T>(static_cast<uintptr_t>(value) & ~(alignment - 1));
}

int main() {
    bool passed = true;

    if (!is_aligned(0x1000, 0x1000)) {
        std::cerr << "FAIL: 0x1000 is not aligned to 4KiB\n";
        passed = false;
    }

    if (is_aligned(0x1001, 0x1000)) {
        std::cerr << "FAIL: 0x1001 falsely reported as aligned to 4KiB\n";
        passed = false;
    }

    if (align_up(0x1001, 0x1000) != 0x2000) {
        std::cerr << "FAIL: align_up(0x1001, 0x1000) != 0x2000\n";
        passed = false;
    }

    if (align_down(0x1fff, 0x1000) != 0x1000) {
        std::cerr << "FAIL: align_down(0x1fff, 0x1000) != 0x1000\n";
        passed = false;
    }

    if (passed) {
        std::cout << "[PASS] Host sanity test suite completed successfully.\n";
        return 0;
    }

    return 1;
}
