import 'dart:io';

void main() {
  print("Adj meg két legfeljebb kétjegyű egész számot:");
  int? num1 = int.parse(stdin.readLineSync()!);
  int? num2 = int.parse(stdin.readLineSync()!);

  if (num1 > num2) {
    int temp = num1;
    num1 = num2;
    num2 = temp;
  }

  for (int i = num1; i <= num2; i++) {
    String parity = (i % 2 == 0) ? "páros" : "páratlan";
    print("$i - $parity");
  }
}