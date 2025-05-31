class UserAccount {
  final String id;
  final String email;
  final String role;

  UserAccount({
    required this.id,
    required this.email,
    required this.role,
  });

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as String,
      email: map['email'] as String,
      role: map['role'] as String? ?? 'N/A',
    );
  }
}
