bool isTriangleByAngles(num a, num b, num c) {
  return a > 0 && b > 0 && c > 0 && (a + b + c == 180);
}

void main() {
  print(isTriangleByAngles(60, 60, 60)); // true
  print(isTriangleByAngles(90, 45, 45)); // true
  print(isTriangleByAngles(0, 90, 90)); // false
}
