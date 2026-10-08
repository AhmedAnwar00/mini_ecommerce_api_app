class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.membershipBasisPoints,
  });

  final String id;
  final String name;
  final String email;
  final int membershipBasisPoints;

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id == null || id.toString().isEmpty) {
      throw const FormatException('User id missing');
    }
    return User(
      id: id.toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      membershipBasisPoints:
          (json['membershipBasisPoints'] as num?)?.toInt() ?? 0,
    );
  }
}
