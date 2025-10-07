dynamic fizzBuzz(int integer) {
  if (integer % 15 == 0) return 'FizzBuzz';
  if (integer % 3 == 0) return 'Fizz';
  if (integer % 5 == 0) return 'Buzz';
  return integer;
}

void main() {
  print(fizzBuzz(3)); // Fizz
  print(fizzBuzz(5)); // Buzz
  print(fizzBuzz(15)); // FizzBuzz
  print(fizzBuzz(7)); // 7
}
