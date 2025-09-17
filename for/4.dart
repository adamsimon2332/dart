void main() {
  print("Adj meg egy számot:");
  String input = stdin.readLineSync()!;
  List<int> digits = input.split('').map(int.parse).toList();
  double average = digits.reduce((a, b) => a + b) / digits.length;
  print("Számjegyek átlaga: ${average.toStringAsFixed(2)}");
}