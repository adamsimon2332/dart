String headTail(String txt) {
  int mid = (txt.length / 2).ceil();
  return txt.substring(mid) + txt.substring(0, mid);
}