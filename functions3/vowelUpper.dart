String vowelUpper(String text) {
  const vowels = 'aeiouAEIOU';
  return text.split('').map((char) {
    if (vowels.contains(char)) {
      return char.toUpperCase();
    } else {
      return char.toLowerCase();
    }
  }).join('');
}