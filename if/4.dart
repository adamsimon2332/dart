import 'dart:io';

void main() {
  print("Add meg a teszt össz pontszámát:");
  int totalPoints = int.parse(stdin.readLineSync()!);

  print("Add meg az elért pontszámot:");
  int achievedPoints = int.parse(stdin.readLineSync()!);

  double percentage = (achievedPoints / totalPoints) * 100;

  String grade;
  if (percentage >= 90) {
    grade = "A";
  } else if (percentage >= 80) {
    grade = "B";
  } else if (percentage >= 70) {
    grade = "C";
  } else if (percentage >= 60) {
    grade = "D";
  } else if (percentage >= 50) {
    grade = "E";
  } else {
    grade = "F";
  }

  print("Az elért százalék: ${percentage.toStringAsFixed(2)}%");
  print("Az értékelés: $grade");
}