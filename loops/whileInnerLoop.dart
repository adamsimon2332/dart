import 'dart:io';

void main() {
  stdout.write('Adj meg egy számot (3 és 9 között): ');
  int? n = int.tryParse(stdin.readLineSync() ?? '');
  if (n == null || n < 3 || n > 9) {
    print('Hibás szám!');
    return;
  }
  int i = 0;
  while (i <= 10) {
    int j = 0;
    while (j <= 10) {
      print('i: ' + i.toString() + ', j: ' + j.toString());
      if (j == n) {
        break;
      }
      j++;
    }
    if (i == n) {
      break;
    }
    i++;
  }
}
