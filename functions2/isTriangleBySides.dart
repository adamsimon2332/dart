bool isTriangleBySides(num a, num b, num c) {
  return a + b > c && a + c > b && b + c > a;
}

void main() {
  print(isTriangleBySides(3, 4, 5)); // true
  print(isTriangleBySides(1, 2, 3)); // false
}
