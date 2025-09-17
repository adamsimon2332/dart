void main() {
  print("Adj meg egy szöveget:");
  String text = stdin.readLineSync()!;
  for (int i = 0; i < text.length; i++) {
    print("(${text[i]}, ${text.codeUnitAt(i)})");
  }
}