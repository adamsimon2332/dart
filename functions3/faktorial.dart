int faktorial(int number) {
  if (number <= 1) return 1;
  return number * faktorial(number - 1);
}