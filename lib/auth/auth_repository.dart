import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_event.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository() : _client = Supabase.instance.client;

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<void> signUp(String email, String password, String username) async {
    final insertResponse = await _client.from('users').insert({
      'username': username,
      'email': email,
      'password': password,
      'role': 'user',
    }).select();

    if (insertResponse == null || (insertResponse is List && insertResponse.isEmpty)) {
      throw Exception('Failed to insert user data: empty response');
    }
  }

  Future<Map<String, dynamic>?> getUserByEmailAndPassword(
      String email, String password) async {
    final response = await _client
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    return null;
  }

  Future<bool> login(String email, String password, UserBloc userBloc) async {
    final user = await getUserByEmailAndPassword(email, password);
    if (user != null && user.containsKey('id')) {
      final userId = user['id'] as String?;
      print('Login berhasil, userId: $userId');

      if (userId != null) {
        await saveUserId(userId);
        userBloc.add(UserLoggedIn(userId));
      }

      return true;
    } else {
      print('Login gagal, user tidak ditemukan');
      return false;
    }
  }

  Future<String?> getUserRole(String userId) async {
    final response =
        await _client.from('users').select('role').eq('id', userId).single();

    if (response == null) {
      throw Exception('Failed to get user role: null response');
    }

    if (response is Map<String, dynamic> && response.containsKey('role')) {
      return response['role'] as String;
    }
    return null;
  }

  Future<String?> getUsernameById(String userId) async {
    final response =
        await _client.from('users').select('username').eq('id', userId).single();

    if (response == null) {
      throw Exception('Failed to get username: null response');
    }

    if (response is Map<String, dynamic> && response.containsKey('username')) {
      return response['username'] as String;
    }
    return null;
  }

  Future<void> signOut(UserBloc userBloc) async {
    await removeUserId();
    userBloc.add(UserLoggedOut());
    await _client.auth.signOut();
  }
}
