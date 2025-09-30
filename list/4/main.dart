void main() {
  List<int> fiboList = [];
  int a = 0, b = 1;
  while (a < 30) {
    fiboList.add(a);
    int temp = a + b;
    a = b;
    b = temp;
  }
  print('Hossz: ${fiboList.length}');
  print('Első elem: ${fiboList.first}');
  print('Utolsó elem: ${fiboList.last}');
  print('3-as indexű elem: ${fiboList[3]}');
  print('8 indexe: ${fiboList.indexOf(8)}');
  print('Fordított sorrend: ${fiboList.reversed.toList()}');
  print('Nem üres-e: ${fiboList.isNotEmpty}');
  fiboList.clear();
  print('Törlés után üres-e: ${fiboList.isEmpty}');
  fiboList.add(34);
  print('Hozzáadva 34: $fiboList');
  fiboList.addAll([1, 2, 3, 5, 7]);
  print('Hozzáadva [1,2,3,5,7]: $fiboList');
  int idx = fiboList.indexOf(34);
  fiboList.insertAll(idx + 1, [0, 1]);
  print('34 után beszúrva [0,1]: $fiboList');
  fiboList[fiboList.length - 1] = 8;
  fiboList.addAll([13, 21]);
  print('Utolsó elem lecserélve [8,13,21]: $fiboList');
  fiboList.removeAt(0);
  print('Első elem törölve: $fiboList');
}
