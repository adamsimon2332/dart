import 'dart:io';

void main() {
  print("Adj meg egy számot:");
  int? number = int.parse(stdin.readLineSync()!);
  print("A megadott szám ${number}");

  if (number % 2 == 0) {
    print("A megadott szám páros");
  } else {
    print("A megadott szám páratlan");
  }

  if (number > 0) {
    print("A megadott szám pozitív");
  } else if (number < 0) {
    print("A megadott szám negatív");
  } else {
    print("A megadott szám a 0");
  }
}
