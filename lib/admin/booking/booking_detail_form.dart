import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/booking_model.dart';
// import 'model/booking_service_model.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'booking_service/booking_print_service.dart';
import 'booking_service/booking_detail_print_service.dart';

class BookingDetailFormPage extends StatefulWidget {
  final BookingModel booking;
  final List<ServiceModel> services;
  final List<Map<String, dynamic>> profiles;
  final List<Map<String, dynamic>> mechanics;

  // ignore: use_super_parameters
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
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        title: const Text(
          'Detail Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Booking',
            onPressed: _printBooking,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildReadOnlyField('User', _getUserFullName() ?? widget.booking.usersId ?? ''),
            _buildReadOnlyField('Mekanik', _getMechanicFullName() ?? widget.booking.mechanicsId ?? ''),
            _buildReadOnlyField('Tanggal Booking', dateText),
            _buildReadOnlyField('Waktu Booking', timeText),
            _buildReadOnlyField('Status', widget.booking.status ?? ''),
            const SizedBox(height: 20),
            const Text(
              'Jasa Servis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.services.map((service) {
              return Card(
                elevation: 2,
                shadowColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.build, color: Colors.amber),
                  title: Text(
                    service.serviceName ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    'Harga: Rp ${service.price?.toString() ?? '-'}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Text(
              'Total Harga: Rp ${widget.booking.totalPrice?.toStringAsFixed(2) ?? '-'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField('Catatan', widget.booking.notes ?? '', maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: Colors.amber[50],
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.amber),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.amber, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
