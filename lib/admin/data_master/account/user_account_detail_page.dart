import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/account/user_account_model.dart';

class UserAccountDetailPage extends StatefulWidget {
  final UserAccount user;

  const UserAccountDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserAccountDetailPage> createState() => _UserAccountDetailPageState();
}

class _UserAccountDetailPageState extends State<UserAccountDetailPage> {
  bool isEditing = false;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  String selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
        text: widget.user.username); // Ganti jika ada username asli
    emailController = TextEditingController(text: widget.user.email);
    selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserAccount() async {
    final supabase = Supabase.instance.client;

    final response =
        await supabase.from('users').select().eq('id', widget.user.id).single();

    // ignore: unnecessary_null_comparison
    if (response != null) {
      setState(() {
        usernameController.text =
            response['username']; // atau username kalau ada
        emailController.text = response['email'];
        selectedRole = response['role'];
      });
    }
  }

  Future<void> _deleteUser() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('users').delete().eq('id', widget.user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dihapus')),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus akun: $e')),
        );
      }
    }
  }

  Future<void> toggleEditSave() async {
    if (isEditing) {
      final updatedUsername = usernameController.text;
      final updatedEmail = emailController.text;
      final updatedRole = selectedRole;

      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('users')
          .update({
            'username': updatedUsername,
            'email': updatedEmail,
            'role': updatedRole,
          })
          .eq('id', widget.user.id)
          .select()
          .single();

      // ignore: unnecessary_null_comparison
      if (response != null && response['email'] != null) {
        setState(() {
          isEditing = false;
          emailController.text = response['email'];
          selectedRole = response['role'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perubahan akun berhasil disimpan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan perubahan')),
        );
      }
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  Widget _buildInputItem(IconData icon, String label, Widget input) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber[700]),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: input,
      ),
    );
  }

  Widget _buildViewOrEditFields() {
    if (isEditing) {
      return Column(
        children: [
          _buildInputItem(
            Icons.person,
            'Username',
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          _buildInputItem(
            Icons.email,
            'Email',
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(border: InputBorder.none),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          _buildInputItem(
            Icons.security,
            'Role',
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(border: InputBorder.none),
              items: ['user', 'admin'].map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildInputItem(
              Icons.person, 'Username', Text(usernameController.text)),
          _buildInputItem(Icons.email, 'Email', Text(emailController.text)),
          _buildInputItem(Icons.security, 'Role', Text(selectedRole)),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Akun'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUserAccount,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.account_circle, size: 100, color: Colors.amber[700]),
              const SizedBox(height: 16),
              _buildViewOrEditFields(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: toggleEditSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isEditing ? Colors.green : Colors.amber[700],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(isEditing ? Icons.save : Icons.edit),
                  label: Text(
                    isEditing ? 'Simpan Perubahan' : 'Edit Akun',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Hapus'),
                        content: const Text(
                            'Apakah Anda yakin ingin menghapus akun ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _deleteUser();
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text(
                    'Hapus Akun',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
