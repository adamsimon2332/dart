String grade(int total, int points) {
  double percentage = (points / total) * 100;
  if (percentage >= 90) return 'A';
  if (percentage >= 75) return 'B';
  if (percentage >= 60) return 'C';
  if (percentage >= 45) return 'D';
  return 'E';
}