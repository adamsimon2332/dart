void main() {
  int intValue = 12;
  double doubleValue = 24.5;
  String strValue = "Dart Program";
  bool boolValue = true;

  int intResult = intValue * 3 + 10;
  double doubleResult = doubleValue / 2 + 10.5;

  print("A változó intValue értéke: $intValue");
  print("A változó doubleValue értéke: $doubleValue");
  print("A változó strValue értéke: $strValue");
  print("A változó boolValue értéke: $boolValue");

  bool boolResult = !boolValue;
  print("A változó boolValue negáltja (boolResult): $boolResult");

  int additionalIntResult = intValue + 100 - 60;
  double additionalDoubleResult = doubleValue * 5.0 - 5.0;

  print("További művelet intValue-val: $additionalIntResult");
  print("További művelet doubleValue-val: $additionalDoubleResult");
}
