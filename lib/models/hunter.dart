class Hunter {
  final int? id;
  final String username;
  final int level;
  final int exp;
  final int gold;

  Hunter({
    this.id,
    required this.username,
    required this.level,
    required this.exp,
    required this.gold,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'level': level,
      'exp': exp,
      'gold': gold,
    };
  }

  factory Hunter.fromMap(Map<String, dynamic> map) {
    return Hunter(
      id: map['id'],
      username: map['username'],
      level: map['level'],
      exp: map['exp'],
      gold: map['gold'],
    );
  }
}