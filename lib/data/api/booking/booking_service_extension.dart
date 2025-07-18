import 'booking_service.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension BookingServiceExtension on BookingService {
  Future<List<ServiceModel>?> getServicesByUserId(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return null;
    }
    try {
      final SupabaseClient client = Supabase.instance.client;
      // Query booking join services to get service details
      final response = await client
          .from('booking')
          .select('services_id, services(service_name, price)')
          .eq('users_id', userId);
      if (response == null) {
        return null;
      }
      List<ServiceModel> services = [];
      for (var item in response) {
        final serviceId = item['services_id'];
        final serviceData = item['services'];
        if (serviceId != null && serviceData != null) {
          services.add(ServiceModel(
            id: serviceId,
            serviceName: serviceData['service_name'] ?? '',
            price: serviceData['price']?.toString() ?? '',
          ));
        }
      }
      return services;
    } catch (e) {
      print('Exception getting services by userId: $e');
      return null;
    }
  }

  Future<List<ServiceModel>?> getServicesByUserIdAndDateTime(String? userId, DateTime? date, String? time) async {
    if (userId == null || userId.isEmpty || date == null || time == null || time.isEmpty) {
      return null;
    }
    try {
      final SupabaseClient client = Supabase.instance.client;
      final dateStr = date.toIso8601String().split('T')[0];
      // Query booking join services to get service details filtered by userId, date, and time
      final response = await client
          .from('booking')
          .select('services_id, services(service_name, price)')
          .eq('users_id', userId)
          .eq('bookings_date', dateStr)
          .eq('bookings_time', time);
      if (response == null) {
        return null;
      }
      List<ServiceModel> services = [];
      for (var item in response) {
        final serviceId = item['services_id'];
        final serviceData = item['services'];
        if (serviceId != null && serviceData != null) {
          services.add(ServiceModel(
            id: serviceId,
            serviceName: serviceData['service_name'] ?? '',
            price: serviceData['price']?.toString() ?? '',
          ));
        }
      }
      return services;
    } catch (e) {
      print('Exception getting services by userId and date/time: $e');
      return null;
    }
  }

  Future<double?> getTotalPriceByUserId(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return null;
    }
    try {
      final SupabaseClient client = Supabase.instance.client;
      final response = await client
          .from('booking')
          .select('total_price')
          .eq('users_id', userId)
          .limit(1)
          .single();
      if (response == null) {
        return null;
      }
      final totalPrice = response['total_price'];
      if (totalPrice is num) {
        return totalPrice.toDouble();
      }
      return null;
    } catch (e) {
      print('Exception getting total price by userId: $e');
      return null;
    }
  }

  Future<bool> updateStatusByUserId(String userId, String status) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final response = await client
          .from('booking')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('users_id', userId)
          .select();
      if (response != null) {
        return false;
      }
      // Jika tidak ada error, anggap berhasil
      return true;
    } catch (e) {
      print('Exception updating status by userId: $e');
      return false;
    }
  }

  Future<bool> updateStatusByUserIdDateTime(String userId, DateTime date, String time, String status) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await client
          .from('booking')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('users_id', userId)
          .eq('bookings_date', dateStr)
          .eq('bookings_time', time)
          .select();
      if (response != null) {
        return false;
      }
      // Jika tidak ada error, anggap berhasil
      return true;
    } catch (e) {
      print('Exception updating status by userId, date, and time: $e');
      return false;
    }
  }

  Future<bool> deleteByUserId(String userId) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final response =
          await client.from('booking').delete().eq('users_id', userId).select();
      if (response != null) {
        return false;
      }
      return true;
    } catch (e) {
      print('Exception deleting booking by userId: $e');
      return false;
    }
  }
}
