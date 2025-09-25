import 'dart:io';
import 'dart:math';

double kupTerfogat(double sugar, double magassag) =>
    (1 / 3) * pi * pow(sugar, 2) * magassag;

double kupFelszin(double sugar, double magassag) {
  double alkoto = sqrt(pow(sugar, 2) + pow(magassag, 2));
  return pi * sugar * (sugar + alkoto);
}

void main() {
  stdout.write('Adj meg egy tizedes számot (a kúp alapjának sugara és magassága): ');
  double input = double.parse(stdin.readLineSync()!);

  print('A kúp térfogata: ${kupTerfogat(input, input)}');
  print('A kúp felszíne: ${kupFelszin(input, input)}');
}