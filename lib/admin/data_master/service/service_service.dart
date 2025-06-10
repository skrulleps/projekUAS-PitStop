import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/service/service_model.dart';

class ServiceService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> addService(Map<String, dynamic> serviceData) async {
    try {
      final response =
          await _client.from('services').insert([serviceData]).select();

      print("Data baru service: $response");
      return true;
    } catch (e) {
      print('Exception inserting service: $e');
      return false;
    }
  }

  Future<List<ServiceModel>?> getServices() async {
    try {
      final response =
          await _client.from('services').select().order('service_name');

      print('Fetched services data: $response');

      if (response != null) {
        return response
            .map((item) => ServiceModel.fromMap(item as Map<String, dynamic>))
            .toList();
      }

      return null;
    } catch (e) {
      print('Exception fetching services: $e');
      return null;
    }
  }

  Future<bool> updateService(
      String id, Map<String, dynamic> updateData) async {
    try {
      updateData['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from('services')
          .update(updateData)
          .eq('id', id)
          .select();

      print('Updated service data: $response');
      return true;
    } catch (e) {
      print('Exception updating service: $e');
      return false;
    }
  }

  Future<bool> deleteService(String id) async {
    try {
      final response = await _client.from('services').delete().eq('id', id);

      print('Deleted service with id: $id');
      return true;
    } catch (e) {
      print('Exception deleting service: $e');
      return false;
    }
  }
}
