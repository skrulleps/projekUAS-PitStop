import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/mechanic_model.dart';

class MechanicService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> addMechanic(Map<String, dynamic> mechanicData) async {
    try {
      final response =
          await _client.from('mechanics').insert([mechanicData]).select();

      print("Data nya adalah: ${response}");
      return true;
    } catch (e) {
      print('Exception inserting mechanic: $e');
      return false;
    }
  }

  Future<List<MechanicModel>?> getMechanics() async {
    try {
      final response = await _client.from('mechanics').select().order('full_name');

      print('Fetched mechanics data: $response');

      if (response != null) {
        return response.map((item) => MechanicModel.fromMap(item as Map<String, dynamic>)).toList();
      }

      return null;
    } catch (e) {
      print('Exception fetching mechanics: $e');
      return null;
    }
  }

  Future<bool> updateMechanic(String id, Map<String, dynamic> updateData) async {
    try {
      final response = await _client
          .from('mechanics')
          .update(updateData)
          .eq('id', id)
          .select();

      print('Updated mechanic data: $response');
      return true;
    } catch (e) {
      print('Exception updating mechanic: $e');
      return false;
    }
  }

  Future<bool> deleteMechanic(String id) async {
    try {
      final response = await _client
          .from('mechanics')
          .delete()
          .eq('id', id);

      print('Deleted mechanic with id: $id');
      return true;
    } catch (e) {
      print('Exception deleting mechanic: $e');
      return false;
    }
  }
}
