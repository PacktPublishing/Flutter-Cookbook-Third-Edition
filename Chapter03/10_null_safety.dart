void main() {
  // 1. Safe initialization
  int someNumber = 0;
  increaseValue(someNumber);

  // 2. Nullable variable
  int? nullableNumber;

  // Using null-coalescing operator (??)
  increaseValueSafe(nullableNumber);

  // 3. Forced access (dangerous)
  try {
    increaseValueForced(nullableNumber);
  } catch (e) {
    print('Caught expected error: $e');
  }
}

void increaseValue(int value) {
  value++;
  print('Result: $value');
}

void increaseValueSafe(int? value) {
  // If value is null, use 0, then add 1
  int result = (value ?? 0) + 1;
  print('Safe Result: $result');
}

void increaseValueForced(int? value) {
  // Using the bang operator (!) - crashes if value is null
  int result = value! + 1;
  print('Forced Result: $result');
}
