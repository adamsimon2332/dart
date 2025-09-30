void main() {
  List<int> fiboList = [];
  int a = 0, b = 1;
  while (a < 30) {
    fiboList.add(a);
    int temp = a + b;
    a = b;
    b = temp;
  }
  List<int> fiboSquare = fiboList.map((e) => e * e).toList();
  List<int> allFibo = [
    ...fiboList.where((e) => e % 2 == 1),
    ...fiboSquare.where((e) => e % 2 == 1)
  ]..sort((a, b) => b.compareTo(a));
  print(allFibo);
}
