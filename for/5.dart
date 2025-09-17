void main() {
  print("Adj meg egy számot:");
  String input = stdin.readLineSync()!;
  List<int> digits = input.split('').map(int.parse).toList();
  List<int> squares = digits.map((d) => d * d).toList();
  print("Számjegyek négyzetei: $squares");
}