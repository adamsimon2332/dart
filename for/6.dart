void main() {
  print("Adj meg egy szöveget:");
  String text = stdin.readLineSync()!;
  String result = text.replaceAll(RegExp(r'[aeiouAEIOUáéíóöőúüűÁÉÍÓÖŐÚÜŰ]'), '');
  print("Szöveg magánhangzók nélkül: $result");
}