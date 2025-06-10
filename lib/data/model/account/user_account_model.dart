class UserAccount {
  final String id;
  final String email;
  final String username;
  final String role;

  UserAccount({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
  });

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String? ?? '',
      role: map['role'] as String? ?? 'N/A',
    );
  }
}
