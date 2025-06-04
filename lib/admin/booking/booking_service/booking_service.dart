import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:pitstop/admin/booking/model/booking_model.dart';
import 'package:pitstop/admin/booking/model/booking_service_model.dart';

<<<<<<< HEAD

=======
>>>>>>> view2
class BookingService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> generateBookingId() async {
    try {
      final response = await _client
          .from('booking')
          .select('id')
          .like('id', 'B%')
          .order('id', ascending: false)
          .limit(1)
          .single();

      if (response == null || response['id'] == null) {
        return 'B001';
      }

      final lastId = response['id'] as String;
      final numberPart = int.tryParse(lastId.substring(1)) ?? 0;
      final newNumber = numberPart + 1;
      return 'B' + newNumber.toString().padLeft(3, '0');
    } catch (e) {
      print('Exception generating booking ID: $e');
      return 'B001';
    }
  }

<<<<<<< HEAD
  Future<bool> addBooking(
      BookingModel booking, List<BookingServiceModel> bookingServices) async {
=======
  Future<bool> addBooking(BookingModel booking, List<BookingServiceModel> bookingServices) async {
>>>>>>> view2
    try {
      for (var bs in bookingServices) {
        final bookingId = await generateBookingId();

<<<<<<< HEAD
        final response = await _client
            .from('booking')
            .insert({
              'id': bookingId,
              'users_id': booking.usersId ?? '',
              'mechanics_id': booking.mechanicsId ?? '',
              'bookings_date': booking.bookingsDate?.toIso8601String() ?? '',
              'bookings_time': booking.bookingsTime ?? '',
              'status': booking.status ?? '',
              'notes': booking.notes ?? '',
              'total_price': booking.totalPrice ?? 0,
              'services_id': bs.serviceId ?? '',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': booking.updatedAt?.toIso8601String() ?? '',
            })
            .select('id')
            .single();
=======
        final response = await _client.from('booking').insert({
          'id': bookingId,
          'users_id': booking.usersId ?? '',
          'mechanics_id': booking.mechanicsId ?? '',
          'bookings_date': booking.bookingsDate?.toIso8601String() ?? '',
          'bookings_time': booking.bookingsTime ?? '',
          'status': booking.status ?? '',
          'notes': booking.notes ?? '',
          'total_price': booking.totalPrice ?? 0,
          'services_id': bs.serviceId ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': booking.updatedAt?.toIso8601String() ?? '',
        }).select('id').single();
>>>>>>> view2

        if (response == null || response['id'] == null) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Exception adding booking: $e');
      return false;
    }
  }

<<<<<<< HEAD
  Future<bool> updateBooking(
      BookingModel booking, List<BookingServiceModel> bookingServices) async {
=======
  Future<bool> updateBooking(BookingModel booking, List<BookingServiceModel> bookingServices) async {
>>>>>>> view2
    try {
      if (booking.id == null) {
        print('DEBUG: booking.id is null');
        return false;
      }

      if (bookingServices.isEmpty) {
        print('DEBUG: bookingServices is empty');
        return false;
      }

      final bs = bookingServices.first;

      print('DEBUG: booking.id: ${booking.id}');
<<<<<<< HEAD
      print(
          'DEBUG: update data: users_id=${booking.usersId}, mechanics_id=${booking.mechanicsId}, bookings_date=${booking.bookingsDate}, bookings_time=${booking.bookingsTime}, status=${booking.status}, notes=${booking.notes}, total_price=${booking.totalPrice}, services_id=${bs.serviceId}, updated_at=${booking.updatedAt}');
=======
      print('DEBUG: update data: users_id=${booking.usersId}, mechanics_id=${booking.mechanicsId}, bookings_date=${booking.bookingsDate}, bookings_time=${booking.bookingsTime}, status=${booking.status}, notes=${booking.notes}, total_price=${booking.totalPrice}, services_id=${bs.serviceId}, updated_at=${booking.updatedAt}');
>>>>>>> view2

      final updateResponse = await _client.from('booking').update({
        'users_id': booking.usersId as Object? ?? '',
        'mechanics_id': booking.mechanicsId as Object? ?? '',
<<<<<<< HEAD
        'bookings_date':
            booking.bookingsDate?.toIso8601String() as Object? ?? '',
=======
        'bookings_date': booking.bookingsDate?.toIso8601String() as Object? ?? '',
>>>>>>> view2
        'bookings_time': booking.bookingsTime as Object? ?? '',
        'status': booking.status as Object? ?? '',
        'notes': booking.notes as Object? ?? '',
        'total_price': booking.totalPrice as Object? ?? 0,
        'services_id': bs.serviceId as Object? ?? '',
        'updated_at': booking.updatedAt?.toIso8601String() as Object? ?? '',
      }).eq('id', booking.id as Object);

      print('DEBUG: updateResponse: $updateResponse');

<<<<<<< HEAD
      if (updateResponse == null ||
          (updateResponse is List && updateResponse.isEmpty)) {
=======
      if (updateResponse == null || (updateResponse is List && updateResponse.isEmpty)) {
>>>>>>> view2
        return false;
      }

      return true;
    } catch (e) {
      print('Exception updating booking: $e');
      return false;
    }
  }

  Future<List<BookingModel>?> getBookings() async {
    try {
<<<<<<< HEAD
      final response = await _client
          .from('booking')
          .select()
          .order('created_at', ascending: false);
=======
      final response = await _client.from('booking').select().order('created_at', ascending: false);
>>>>>>> view2
      if (response == null) {
        return null;
      }
      return (response as List).map((e) => BookingModel.fromMap(e)).toList();
    } catch (e) {
      print('Exception getting bookings: $e');
      return null;
    }
  }

<<<<<<< HEAD
  Future<List<ServiceModel>?> getAllServices() async {
    try {
      final response =
          await _client.from('services').select().order('service_name');
      if (response == null) {
        return null;
      }
      return (response as List).map((e) => ServiceModel.fromMap(e)).toList();
    } catch (e) {
      print('Exception getting all services: $e');
      return null;
=======
  Future<bool> deleteBooking(String id) async {
    try {
      await _client.from('booking').delete().eq('id', id);
      // Anggap berhasil jika tidak ada exception
      return true;
    } catch (e) {
      print('Exception deleting booking: $e');
      return false;
>>>>>>> view2
    }
  }

  Future<List<BookingModel>?> getBookingsByDateAndMechanic(DateTime date, String mechanicId) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await _client
          .from('booking')
          .select()
          .eq('bookings_date', dateStr)
          .eq('mechanics_id', mechanicId)
          .order('bookings_time', ascending: true);
      if (response == null) {
        return null;
      }
      return (response as List).map((e) => BookingModel.fromMap(e)).toList();
    } catch (e) {
      print('Exception getting bookings by date and mechanic: $e');
      return null;
    }
  }

<<<<<<< HEAD
  Future<bool> deleteBooking(String id) async {
    try {
      await _client.from('booking').delete().eq('id', id);
      // Assume success if no exception
      return true;
    } catch (e) {
      print('Exception deleting booking: $e');
      return false;
    }
  }

  Future<bool> deleteByDateAndTime(DateTime date, String time) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      await _client
          .from('booking')
          .delete()
          .eq('bookings_date', dateStr)
          .eq('bookings_time', time);
      // Assume success if no exception
      return true;
    } catch (e) {
      print('Exception deleting bookings by date and time: $e');
      return false;
    }
  }
}


=======
  Future<List<ServiceModel>?> getServicesByUserId(String userId) async {
    try {
      final response = await _client
          .from('booking')
          .select('services_id')
          .eq('users_id', userId);
      if (response == null) {
        return null;
      }
      final serviceIds = (response as List).map((e) => e['services_id'] as String).toSet().toList();
      if (serviceIds.isEmpty) {
        return [];
      }
      final servicesResponse = await _client
          .from('services')
          .select()
          .filter('id', 'in', serviceIds);
      if (servicesResponse == null) {
        return null;
      }
      return (servicesResponse as List).map((e) => ServiceModel.fromMap(e)).toList();
    } catch (e) {
      print('Exception getting services by userId: $e');
      return null;
    }
  }
}
>>>>>>> view2
