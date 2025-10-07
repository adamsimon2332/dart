int sortNumbersAsc(int integer) {
  String sorted = integer.abs().toString().split('')..sort();
  int result = int.parse(sorted.join());
  return integer < 0 ? -result : result;
}

void main() {
  print(sortNumbersAsc(4312)); // 1234
  print(sortNumbersAsc(-4312)); // -1234
}
