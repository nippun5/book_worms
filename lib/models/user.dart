enum UserRole { reader, admin }

UserRole userRoleFromString(String value) =>
    UserRole.values.firstWhere((e) => e.name == value, orElse: () => UserRole.reader);

class AppUser {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String bio;
  final int avatarColorValue;
  final UserRole role;
  final bool isBanned;
  final DateTime createdAt;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.bio = '',
    required this.avatarColorValue,
    this.role = UserRole.reader,
    this.isBanned = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? bio,
    int? avatarColorValue,
    UserRole? role,
    bool? isBanned,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      bio: bio ?? this.bio,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'bio': bio,
      'avatarColorValue': avatarColorValue,
      'role': role.name,
      'isBanned': isBanned ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
      bio: map['bio'] as String? ?? '',
      avatarColorValue: map['avatarColorValue'] as int,
      role: userRoleFromString(map['role'] as String),
      isBanned: (map['isBanned'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
