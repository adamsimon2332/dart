num reverseNumber(num number) {
  String reversed = number.abs().toString().split('').reversed.join();
  num result = number is int ? int.parse(reversed) : double.parse(reversed);
  return number < 0 ? -result : result;
}

void main() {
  print(reverseNumber(123.45)); // 54.321
  print(reverseNumber(-67.89)); // -98.76
}
