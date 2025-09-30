void main() {
  List<int> fixList = List.filled(10, 0);
  for (int i = 1; i < fixList.length; i += 2) {
    fixList[i] = 1;
  }
  print(fixList);
}
