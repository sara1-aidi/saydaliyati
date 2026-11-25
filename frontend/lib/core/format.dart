/// 12500 -> "12 500 DA"  (Algerian dinar, grouped by thousands)
String formatDA(int amount) {
  final s = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('\u00A0');
    buf.write(s[i]);
  }
  return '${amount < 0 ? '-' : ''}$buf\u00A0DA';
}
