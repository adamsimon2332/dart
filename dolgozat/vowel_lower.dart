String vowelLower(String txt) {
  const vowels = "aeiouAEIOU";
  return txt.split('').map((char) {
    if (vowels.contains(char)) {
      return char.toLowerCase();
    } else {
      return char.toUpperCase();
    }
  }).join('');
}