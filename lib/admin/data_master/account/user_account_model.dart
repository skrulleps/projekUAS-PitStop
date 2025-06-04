class UserAccount {
  final String id;
  final String email;
<<<<<<< HEAD
  final String username;
=======
>>>>>>> view2
  final String role;

  UserAccount({
    required this.id,
    required this.email,
<<<<<<< HEAD
    required this.username,
=======
>>>>>>> view2
    required this.role,
  });

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as String,
      email: map['email'] as String,
<<<<<<< HEAD
      username: map['username'] as String? ?? '',
=======
>>>>>>> view2
      role: map['role'] as String? ?? 'N/A',
    );
  }
}
