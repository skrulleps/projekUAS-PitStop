import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/booking_model.dart';
import 'model/booking_service_model.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'booking_service/booking_print_service.dart';
import 'booking_service/booking_detail_print_service.dart';

class BookingDetailFormPage extends StatefulWidget {
  final BookingModel booking;
  final List<ServiceModel> services;
  final List<Map<String, dynamic>> profiles;
  final List<Map<String, dynamic>> mechanics;

  const BookingDetailFormPage({
    Key? key,
    required this.booking,
    required this.services,
    required this.profiles,
    required this.mechanics,
  }) : super(key: key);

  @override
  State<BookingDetailFormPage> createState() => _BookingDetailFormPageState();
}

class _BookingDetailFormPageState extends State<BookingDetailFormPage> {
  String? _getUserFullName() {
    try {
      final profile = widget.profiles.firstWhere(
          (p) => p['users_id'] == widget.booking.usersId,
          orElse: () => {});
      return profile['full_name'] ?? '-';
    } catch (e) {
      return '-';
    }
  }

  String? _getMechanicFullName() {
    try {
      final mechanic = widget.mechanics.firstWhere(
          (m) => m['id'] == widget.booking.mechanicsId,
          orElse: () => {});
      return mechanic['full_name'] ?? '-';
    } catch (e) {
      return '-';
    }
  }

  Future<void> _printBooking() async {
    final bookingDetailPrintService = BookingDetailPrintService();

    final userFullName = _getUserFullName() ?? widget.booking.usersId ?? '-';
    final mechanicFullName = _getMechanicFullName() ?? widget.booking.mechanicsId ?? '-';

    await bookingDetailPrintService.printBookingDetail(
      booking: widget.booking,
      services: widget.services,
      userFullName: userFullName,
      mechanicFullName: mechanicFullName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = widget.booking.bookingsDate != null
        ? DateFormat('yyyy-MM-dd').format(widget.booking.bookingsDate!)
        : '';
    final timeText = widget.booking.bookingsTime ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Booking',
            onPressed: _printBooking,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              initialValue: _getUserFullName() ?? widget.booking.usersId ?? '',
              decoration: const InputDecoration(labelText: 'User'),
              readOnly: true,
            ),
            TextFormField(
              initialValue: _getMechanicFullName() ?? widget.booking.mechanicsId ?? '',
              decoration: const InputDecoration(labelText: 'Mekanik'),
              readOnly: true,
            ),
            TextFormField(
              initialValue: dateText,
              decoration: const InputDecoration(labelText: 'Tanggal Booking'),
              readOnly: true,
            ),
            TextFormField(
              initialValue: timeText,
              decoration: const InputDecoration(labelText: 'Waktu Booking'),
              readOnly: true,
            ),
            TextFormField(
              initialValue: widget.booking.status ?? '',
              decoration: const InputDecoration(labelText: 'Status'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            const Text('Jasa Servis'),
            ...widget.services.map((service) {
              return ListTile(
                title: Text(service.serviceName ?? '-'),
                subtitle: Text('Harga: Rp ${service.price ?? '-'}'),
              );
            }).toList(),
            const SizedBox(height: 16),
            Text('Total Harga: Rp ${widget.booking.totalPrice?.toStringAsFixed(2) ?? '-'}'),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.booking.notes ?? '',
              decoration: const InputDecoration(labelText: 'Catatan'),
              maxLines: 3,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
