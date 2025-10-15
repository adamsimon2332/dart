String evenFizz(int number) {
  if (number % 2 == 0 && number % 3 == 0) {
    return "EvenFizz";
  } else if (number % 2 == 0) {
    return "Even";
  } else if (number % 3 == 0) {
    return "Fizz";
  } else {
    return number.toString();
  }
}