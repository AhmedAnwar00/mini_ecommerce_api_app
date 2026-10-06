class Money {
  const Money(this.minor);

  final int minor;

  static const zero = Money(0);

  Money operator +(Money other) => Money(minor + other.minor);

  Money operator -(Money other) => Money(minor - other.minor);

  @override
  bool operator ==(Object other) => other is Money && other.minor == minor;

  @override
  int get hashCode => minor.hashCode;
}

int percentOfMinor(int amountMinor, int basisPoints) {
  if (amountMinor <= 0 || basisPoints <= 0) return 0;
  final rate = basisPoints > 10000 ? 10000 : basisPoints;
  return (amountMinor * rate + 5000) ~/ 10000;
}
