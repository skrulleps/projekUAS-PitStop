import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../admin_sidebar.dart';
import 'user_account_model.dart';

class DataAkunPage extends StatefulWidget {
  const DataAkunPage({Key? key}) : super(key: key);

  @override
  State<DataAkunPage> createState() => _DataAkunPageState();
}

class _DataAkunPageState extends State<DataAkunPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<UserAccount>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = fetchUsers();
  }

  Future<List<UserAccount>> fetchUsers() async {
    final response = await supabase.from('users').select('id, email, role');
    if (response == null) {
      throw Exception('Failed to load users: response is null');
    }
    final List data = response as List;
    return data.map((e) => UserAccount.fromMap(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Akun'),
      ),
      drawer: const AdminSidebar(),
      body: FutureBuilder<List<UserAccount>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.email),
                  subtitle: Text('Role: ${user.role}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
