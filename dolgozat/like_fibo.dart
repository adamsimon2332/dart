List<int> likeFibo(int number) {
  if (number == 0) return [];
  if (number == 1) return [0];
  if (number == 2) return [0, 1];

  List<int> result = [0, 1, 1];
  for (int i = 3; i < number; i++) {
    result.add(result[i - 1] + result[i - 3]);
  }
  return result;
}