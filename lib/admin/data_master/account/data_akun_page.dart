import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../admin_sidebar.dart';
import 'user_account_model.dart';
<<<<<<< HEAD
import 'user_account_detail_page.dart';
import 'tambah_akun_page.dart';
=======
>>>>>>> view2

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
<<<<<<< HEAD
    final response =
        await supabase.from('users').select('id, email, username, role');
=======
    final response = await supabase.from('users').select('id, email, role');
>>>>>>> view2
    if (response == null) {
      throw Exception('Failed to load users: response is null');
    }
    final List data = response as List;
    return data.map((e) => UserAccount.fromMap(e)).toList();
  }

<<<<<<< HEAD
  Future<void> _refreshData() async {
    setState(() {
      _usersFuture = fetchUsers();
    });
    await _usersFuture;
  }

  void _addUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserAccountPage()),
    );

    if (result == true) {
      _refreshData(); // auto fetch ulang setelah kembali dari add user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Data Akun'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      drawer: const AdminSidebar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Akun'),
      ),
      drawer: const AdminSidebar(),
>>>>>>> view2
      body: FutureBuilder<List<UserAccount>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
<<<<<<< HEAD
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada akun ditemukan.'));
          } else {
            final users = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Colors.black54),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(user.email),
                        ],
                      ),
                      subtitle: Text('Role: ${user.role}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserAccountDetailPage(user: user),
                          ),
                        );

                        if (result == true) {
                          // Fetch ulang data setelah user dihapus
                          _refreshData();
                        }
                      },
                    ),
                  );
                },
              ),
=======
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
>>>>>>> view2
            );
          }
        },
      ),
    );
  }
}
