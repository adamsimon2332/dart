import 'dart:io';

void main() {
  print("Add meg az 1. számot:");
  int? number = int.parse(stdin.readLineSync()!);
  print("A megadott szám ${number}");

  print("Add meg a 2. számot:");
  int? number2 = int.parse(stdin.readLineSync()!);
  print("A megadott szám ${number2}");

  var larger = (number > number2) ? number : number2;
  print("A nagyobb szám a ${larger}");

  var difference;
  if (larger == number) {
    difference = number - number2;
    print("Az eltérés a 2 szám között ${difference}");
  } else if (larger == number2) {
    difference = number2 - number;
    print("Az eltérés a 2 szám között ${difference}");
  }
}
