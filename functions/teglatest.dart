import 'dart:io';

double terfogat(double a, double b, double c) => a * b * c;

double felulet(double a, double b, double c) =>
    2 * (abTerulete(a, b) + acTerulete(a, c) + bcTerulete(b, c));

double abTerulete(double a, double b) => a * b;

double acTerulete(double a, double c) => a * c;

double bcTerulete(double b, double c) => b * c;

void main() {
  stdout.write('Add meg az a él hosszát: ');
  double a = double.parse(stdin.readLineSync()!);

  stdout.write('Add meg a b él hosszát: ');
  double b = double.parse(stdin.readLineSync()!);

  stdout.write('Add meg a c él hosszát: ');
  double c = double.parse(stdin.readLineSync()!);

  print('A téglatest térfogata: ${terfogat(a, b, c)}');
  print('A téglatest felszíne: ${felulet(a, b, c)}');
  print('Az ab lap területe: ${abTerulete(a, b)}');
  print('Az ac lap területe: ${acTerulete(a, c)}');
  print('A bc lap területe: ${bcTerulete(b, c)}');
}