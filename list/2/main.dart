void main() {
  List<int> list = List.generate(10, (i) => i % 2 == 0 ? 1 : 0);
  print(list);
}
