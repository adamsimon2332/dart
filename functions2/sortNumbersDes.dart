int sortNumbersDes(num number) {
  List<String> sorted = number.abs().toString().split('')..sort((a, b) => b.compareTo(a));
  int result = int.parse(sorted.join());
  return number < 0 ? -result : result;
}

void main() {
  print(sortNumbersDes(4312)); // 4321
  print(sortNumbersDes(-4312)); // -4321
}
