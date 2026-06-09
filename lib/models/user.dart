class User {
  final int? id;
  final String username;
  final String passwordHash;

  User({
    this.id,
    required this.username,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      passwordHash: map['passwordHash'],
    );
  }
}