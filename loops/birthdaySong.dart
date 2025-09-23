import 'dart:io';

void main() {
  stdout.write('Adj meg egy számot (1 és 100 között): ');
  int? n = int.tryParse(stdin.readLineSync() ?? '');
  if (n == null || n < 1 || n > 100) {
    print('Hibás szám!');
    return;
  }
  for (int i = 0; i < n; i++) {
    print('Happy birthday!');
    print('Happy birthday to you!');
  }
}
