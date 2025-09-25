import 'dart:io';

String getName(String prompt) {
  stdout.write(prompt);
  return stdin.readLineSync() ?? '';
}

String fullName() {
  String firstName = getName('Add meg a vezetékneved: ');
  String lastName = getName('Add meg az utóneved: ');
  return '$firstName $lastName';
}

void main() {
  print('Teljes név: ${fullName()}');
}