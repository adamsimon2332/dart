int padovanNumber(int n) {
  if (n == 0) return 0;
  if (n == 1 || n == 2) return 1;
  List<int> padovan = [0, 1, 1];
  for (int i = 3; i <= n; i++) {
    padovan.add(padovan[i - 2] + padovan[i - 3]);
  }
  return padovan[n];
}

void main() {
  for (int i = 0; i < 13; i++) {
    print(padovanNumber(i));
  }
}
