class User {
  final String id;
  final String name;
  final int age;
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.age,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  User copyWith({
    String? name,
    int? age,
    String? photoUrl,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }
}
