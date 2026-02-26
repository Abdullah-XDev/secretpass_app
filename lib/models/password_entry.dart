class PasswordEntry {
  final String id;
  final String username; // email or username
  final String accountName; // optional label e.g. "Google Work"
  final String password;
  final String? website;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PasswordEntry({
    required this.id,
    required this.username,
    required this.accountName,
    required this.password,
    this.website,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'accountName': accountName,
      'password': password,
      'website': website,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'],
      username: map['username'],
      accountName: map['accountName'],
      password: map['password'],
      website: map['website'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  PasswordEntry copyWith({
    String? username,
    String? accountName,
    String? password,
    String? website,
    String? notes,
  }) {
    return PasswordEntry(
      id: id,
      username: username ?? this.username,
      accountName: accountName ?? this.accountName,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
