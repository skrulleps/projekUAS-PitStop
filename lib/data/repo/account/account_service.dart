import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pitstop/data/model/account/user_account_model.dart';

class AccountService {
  final SupabaseClient supabase;

  AccountService(this.supabase);

  Future<List<UserAccount>> fetchUsers() async {
    try {
      final response = await supabase.from('users').select('id, email, username, role');
      // ignore: unnecessary_null_comparison
      if (response == null) {
        throw Exception('Failed to fetch users: $response');
      }
      final List data = response as List;
      return data.map((e) => UserAccount.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
