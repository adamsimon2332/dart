void main() {
  String falvedo = "Akár milyen kedves vendég, három napig untig elég";

  print("Eredeti vers: $falvedo");

  print("Kisbetűvel: ${falvedo.toLowerCase()}");

  print("Nagybetűvel: ${falvedo.toUpperCase()}");

  print("Trimmelve: ${falvedo.trim()}");

  print("Szóközök kötőjellel: ${falvedo.replaceAll(' ', '-')}");

  String part1 = falvedo.substring(4);
  print("Az 5. karaktertől a végéig: ...$part1");

  String first3 = falvedo.substring(0, 3);
  print("Az első 3 karakter UTF-16 kódja: "
  "${first3.codeUnits.map((e) => e.toString()).join(", ")}");

  String part2 = falvedo.substring(9);
  print("A 10. karaktertől a végéig: $part2...");
}
