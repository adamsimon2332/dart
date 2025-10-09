double percent(int total, int score) {
  return double.parse(((score / total) * 100).toStringAsFixed(2));
}