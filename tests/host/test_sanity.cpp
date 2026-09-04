#include <cstddef>
#include <cstdint>
#include <iostream>

/*
 * Bit manipulation and alignement helper definition
 * these will be part of freestanding kernel utilities later
 */
template <typename T> constexpr bool is_aligned(T value, size_t alignement) {
  return (static_cast<uintptr_t)(value) & (alignement - 1)) == 0;
}

template<typename T>
constexpr T align_up((T value, size_t alignement) {
  return static_cast<T>((static_cast<uintptr_t)(value)+ (alignement -1)) & ~(alignement -1));
}

template<typename T>
                     constexpr T align_down(T value, size_t alignement) {
  return static_cast<T>(static_cast<uintptr_t>(value) & ~(alignement - 1));
}

int main(){
  bool passed = true;

  if (!is_aligned(0x1000, 0x1000)) {
    std::cerr << "FAIL: 0x1000 is not aligned to 4kib\n";
    passed = false;
  }

  if (is_aligned(0x1001, 0x1000)) {
    std::cerr << "FAIL: x1001 falsely reported as aligned to 4Kib\n";
    passed = false;
  }

  if (align_up(0x1001, 0x1000)) {
    std::cerr << "FAIL: align_up(0x1001, 0x1000 != 0x2000\n";
    passed = false;
  }

  if (align_down(01fff, 0x1000) != 0x1000) {
    std::cerr << "fail: align_down(0x1fff, 0x1000) != 0x1000\n";
    passed = false;
  }

  if (passed) {
    std::cout << "[PASS] Host sanity test suite completed  successfully.\n";
    return 0;
  }

  return 1;
}
