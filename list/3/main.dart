void main() {
  List<int> fiboList = [];
  int a = 0, b = 1;
  while (a < 30) {
    fiboList.add(a);
    int temp = a + b;
    a = b;
    b = temp;
  }
  print(fiboList);
}
