String triangleTypeByAngles(num a, num b, num c) {
  if (!isTriangleByAngles(a, b, c)) return 'érvénytelen háromszög';
  List<num> angles = [a, b, c];
  if (angles.every((e) => e == 60)) return 'egyenlő oldalú háromszög';
  if (angles.where((e) => e == 90).length == 1) return 'derékszögű háromszög';
  if (angles.any((e) => e > 90)) return 'tompaszögű háromszög';
  if (angles.every((e) => e < 90)) return 'hegyesszögű háromszög';
  if (angles.toSet().length == 2) return 'egyenlő szárú háromszög';
  return 'általános háromszög';
}

bool isTriangleByAngles(num a, num b, num c) {
  return a > 0 && b > 0 && c > 0 && (a + b + c == 180);
}

void main() {
  print(triangleTypeByAngles(60, 60, 60)); // egyenlő oldalú háromszög
  print(triangleTypeByAngles(90, 45, 45)); // derékszögű háromszög
  print(triangleTypeByAngles(100, 40, 40)); // tompaszögű háromszög
  print(triangleTypeByAngles(70, 60, 50)); // hegyesszögű háromszög
  print(triangleTypeByAngles(80, 80, 20)); // egyenlő szárú háromszög
  print(triangleTypeByAngles(100, 50, 30)); // általános háromszög
  print(triangleTypeByAngles(0, 90, 90)); // érvénytelen háromszög
}
