import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:pitstop/admin/booking/model/booking_model.dart';
import 'package:pitstop/admin/booking/model/booking_service_model.dart';

class BookingService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> addBooking(BookingModel booking, List<BookingServiceModel> bookingServices) async {
    try {
      final uuid = Uuid();

      for (var bs in bookingServices) {
        final bookingId = uuid.v4();

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

  Future<bool> updateBooking(BookingModel booking, List<BookingServiceModel> bookingServices) async {
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
      print('DEBUG: update data: users_id=${booking.usersId}, mechanics_id=${booking.mechanicsId}, bookings_date=${booking.bookingsDate}, bookings_time=${booking.bookingsTime}, status=${booking.status}, notes=${booking.notes}, total_price=${booking.totalPrice}, services_id=${bs.serviceId}, updated_at=${booking.updatedAt}');

      final updateResponse = await _client.from('booking').update({
        'users_id': booking.usersId as Object? ?? '',
        'mechanics_id': booking.mechanicsId as Object? ?? '',
        'bookings_date': booking.bookingsDate?.toIso8601String() as Object? ?? '',
        'bookings_time': booking.bookingsTime as Object? ?? '',
        'status': booking.status as Object? ?? '',
        'notes': booking.notes as Object? ?? '',
        'total_price': booking.totalPrice as Object? ?? 0,
        'services_id': bs.serviceId as Object? ?? '',
        'updated_at': booking.updatedAt?.toIso8601String() as Object? ?? '',
      }).eq('id', booking.id as Object);

      print('DEBUG: updateResponse: $updateResponse');

      if (updateResponse == null || (updateResponse is List && updateResponse.isEmpty)) {
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
      final response = await _client.from('booking').select().order('created_at', ascending: false);
      if (response == null) {
        return null;
      }
      return (response as List).map((e) => BookingModel.fromMap(e)).toList();
    } catch (e) {
      print('Exception getting bookings: $e');
      return null;
    }
  }

  Future<bool> deleteBooking(String id) async {
    try {
      await _client.from('booking').delete().eq('id', id);
      // Anggap berhasil jika tidak ada exception
      return true;
    } catch (e) {
      print('Exception deleting booking: $e');
      return false;
    }
  }
}
