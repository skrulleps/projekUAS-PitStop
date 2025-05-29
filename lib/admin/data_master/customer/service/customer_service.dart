import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/customer_model.dart';

class CustomerService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final response =
          await _client.from('profiles').insert([customerData]).select();

      print("Data baru customer: $response");
      return true;
    } catch (e) {
      print('Exception inserting customer: $e');
      return false;
    }
  }

  Future<List<CustomerModel>?> getCustomers() async {
    try {
      final response = await _client.from('profiles').select().order('full_name');

      print('Fetched customers data: $response');

      if (response != null) {
        return response
            .map((item) => CustomerModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      return null;
    } catch (e) {
      print('Exception fetching customers: $e');
      return null;
    }
  }

  Future<bool> updateCustomer(String id, Map<String, dynamic> updateData) async {
    try {
      updateData['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from('profiles')
          .update(updateData)
          .eq('id', id)
          .select();

      print('Updated customer data: $response');
      return true;
    } catch (e) {
      print('Exception updating customer: $e');
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      final response = await _client.from('profiles').delete().eq('id', id);

      print('Deleted customer with id: $id');
      return true;
    } catch (e) {
      print('Exception deleting customer: $e');
      return false;
    }
  }
}
