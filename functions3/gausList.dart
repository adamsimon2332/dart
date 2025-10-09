List<int> gausList(int number) {
  List<int> result = [];
  for (int i = 1; i <= number; i++) {
    result.add(gausSum(i));
  }
  return result;
}

int gausSum(int number) {
  return (number * (number + 1)) ~/ 2;
}