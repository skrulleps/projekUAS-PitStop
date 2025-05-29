import 'package:flutter/material.dart';
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'package:pitstop/admin/booking/booking_form.dart';
import 'package:pitstop/admin/booking/edit_booking_form.dart';
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'model/booking_model.dart';
import 'booking_service/booking_service.dart';
import 'booking_service/booking_service_extension.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  BookingModel? _findBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });
    final bookings = await _bookingService.getBookings();
    // Group bookings by users_id to show only one ListTile per users_id
    final Map<String?, BookingModel> uniqueBookings = {};
    if (bookings != null) {
      for (var booking in bookings) {
        if (!uniqueBookings.containsKey(booking.usersId)) {
          uniqueBookings[booking.usersId] = booking;
        }
      }
    }
    setState(() {
      _bookings = uniqueBookings.values.toList();
      _isLoading = false;
    });
  }

  void _navigateToAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookingFormPage()),
    );
    if (result == true) {
      _fetchBookings();
    }
  }

  void _navigateToEdit(BookingModel booking) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditBookingFormPage(booking: booking)),
    );
    if (result == true) {
      _fetchBookings();
    }
  }

  void _navigateToDetail(BookingModel booking) {
    // TODO: implement navigation to booking detail page
  }

  Future<void> _deleteBooking(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus booking ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Cari booking berdasarkan id untuk dapatkan users_id
      BookingModel? booking;
      try {
        booking = _bookings.firstWhere((b) => b.id == id);
      } catch (e) {
        booking = null;
      }
      if (booking == null || booking.usersId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking tidak ditemukan')),
        );
        return;
      }
      // Hapus booking berdasarkan users_id
      final success = await _bookingService.deleteByUserId(booking.usersId!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Semua booking dengan user ini berhasil dihapus')),
        );
        _fetchBookings();
      } else {
        debugPrint('Berhasil menghapus booking');
        _fetchBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAdd,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('Belum ada data booking'))
              : ListView.builder(
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return ListTile(
                      title: Text('Booking ID: ${booking.id ?? '-'}'),
                      subtitle: Text('Status: ${booking.status ?? '-'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToEdit(booking),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              if (booking.id != null) {
                                _deleteBooking(booking.id!);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        final services = await _bookingService
                            .getServicesByUserId(booking.usersId);
                        if (services != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingDetailFormPage(
                                  booking: booking, services: services),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
