import 'dart:io';
// import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/customer/customer_model.dart';

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
      final response =
          await _client.from('profiles').select().order('full_name');

      print('Fetched customers data: $response');

      // ignore: unnecessary_null_comparison
      if (response != null) {
        return response
            // ignore: unnecessary_cast
            .map((item) => CustomerModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      return null;
    } catch (e) {
      print('Exception fetching customers: $e');
      return null;
    }
  }

  Future<bool> updateCustomer(
      String id, Map<String, dynamic> updateData) async {
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

  // Future<String?> uploadAvatar(File file, {String? userId}) async {
  //   try {
  //     final fileName = userId != null ? '$userId.jpg' : '${DateTime.now().millisecondsSinceEpoch}.jpg';

  //     // Upload ke bucket 'avatar'
  //     final response = await _client.storage
  //         .from('avatar')
  //         .upload('public/$fileName', file,
  //             fileOptions: const FileOptions(upsert: true));

  //     if (response != null) {
  //       throw Exception('Upload error: ${response}');
  //     }

  //     // Simpan path ke profile.avatar_path jika userId ada
  //     final path = 'public/$fileName';

  //     print('Uploaded avatar path: $path');

  //     if (userId != null) {
  //       final updateResponse = await _client.from('profiles').update({
  //         'photos': path,
  //         'avatar_path': path,
  //       }).eq('users_id', userId);

  //       if (updateResponse.error != null) {
  //         throw Exception('Update avatar_path error: ${updateResponse.error!.message}');
  //       }
  //     }

  //     return path;
  //   } catch (e) {
  //     print('Exception in uploadAvatar: $e');
  //     return null;
  //   }
  // }

  Future<String?> uploadAvatar(File file, {String? userId}) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }

      final fileName = userId != null
          ? '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final response = await _client.storage
          .from('avatar')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      // if (response != null) {
      //   throw Exception('Upload error: ${response}');
      // }

      final path = fileName;
      print('Uploaded avatar path: $path');
      print('Uploaded avatar response: $response');

      if (userId != null) {
      final updateResponse = await _client
          .from('profiles')
          .update({
            'photos': path,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('users_id', userId).select();

        if (updateResponse != null) {
          throw Exception(
              'Update avatar_path error: ${updateResponse}');
        }
      }

      return path;
    } catch (e) {
      print('Exception in uploadAvatar: $e');
      return null;
    }
  }

  String getAvatarUrl(String avatarPath) {
    return _client.storage.from('avatar').getPublicUrl(avatarPath);
  }
}
