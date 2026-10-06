String formatMinorUnits(int minor) {
  final negative = minor < 0;
  final value = minor.abs();
  final major = value ~/ 100;
  final fraction = (value % 100).toString().padLeft(2, '0');
  final text = '$major.$fraction';
  return negative ? '-$text' : text;
}
