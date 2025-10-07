int reverseInteger(int integer) {
  String reversed = integer.abs().toString().split('').reversed.join();
  int result = int.parse(reversed);
  return integer < 0 ? -result : result;
}

void main() {
  print(reverseInteger(1234)); // 4321
  print(reverseInteger(-567)); // -765
}
