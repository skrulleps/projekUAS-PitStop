import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddUserAccountPage extends StatefulWidget {
  const AddUserAccountPage({Key? key}) : super(key: key);

  @override
  State<AddUserAccountPage> createState() => _AddUserAccountPageState();
}

class _AddUserAccountPageState extends State<AddUserAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user';
  bool _obscurePassword = true; // ⬅️ Tambahkan ini
  final supabase = Supabase.instance.client;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.contains(' ')) return 'Password tidak boleh mengandung spasi';
    if (value.length < 8) return 'Minimal 8 karakter';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Harus ada huruf besar';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Harus ada huruf kecil';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Harus ada angka';
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final email = _emailController.text.trim();
        final username = _usernameController.text.trim();
        final password = _passwordController.text.trim();

        await supabase.from('users').insert({
          'email': email,
          'username': username,
          'password': password,
          'role': _role,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil ditambahkan')),
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan akun: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Akun'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Username wajib diisi'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              const Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                value: 'user',
                groupValue: _role,
                title: const Text('User'),
                onChanged: (value) {
                  setState(() => _role = value!);
                },
              ),
              RadioListTile<String>(
                value: 'admin',
                groupValue: _role,
                title: const Text('Admin'),
                onChanged: (value) {
                  setState(() => _role = value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
