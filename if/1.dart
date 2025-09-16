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

  if (number == 1) {
    print("Elégtelen");
  } else if (number == 2) {
    print("Elégséges");
  } else if (number == 3) {
    print("Közepes");
  } else if (number == 4) {
    print("Jó");
  } else if (number == 5) {
    print("Jeles");
  } else {
    print("A megadott szám nem felel meg osztályzatnak");
  }

  switch (number) {
    case 1:
      print("Elégtelen");
      break;
    case 2:
      print("Elégséges");
      break;
    case 3:
      print("Közepes");
      break;
    case 4:
      print("Jó");
      break;
    case 5:
      print("Jeles");
      break;
    default:
      print("A megadott szám nem felel meg osztályzatnak");
      break;
  }

  assert(
      number < 1 || number > 5, "A megadott szám nem felel meg osztályzatnak");
}
