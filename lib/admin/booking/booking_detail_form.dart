import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/booking_model.dart';
import 'model/booking_service_model.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';

class BookingDetailFormPage extends StatelessWidget {
  final BookingModel booking;
  final List<ServiceModel> services;

  const BookingDetailFormPage({Key? key, required this.booking, required this.services}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateText = booking.bookingsDate != null ? DateFormat('yyyy-MM-dd').format(booking.bookingsDate!) : '';
    final timeText = booking.bookingsTime ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              initialValue: booking.usersId ?? '',
              decoration: const InputDecoration(labelText: 'User ID'),
              readOnly: true,
            ),
            TextFormField(
              initialValue: booking.mechanicsId ?? '',
              decoration: const InputDecoration(labelText: 'Mekanik ID'),
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
              initialValue: booking.status ?? '',
              decoration: const InputDecoration(labelText: 'Status'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            const Text('Jasa Servis'),
            ...services.map((service) {
              return ListTile(
                title: Text(service.serviceName ?? '-'),
            subtitle: Text('Harga: Rp ${service.price ?? '-'}'),
          );
        }).toList(),
        const SizedBox(height: 16),
        Text('Total Harga: Rp ${booking.totalPrice?.toStringAsFixed(2) ?? '-'}'),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: booking.notes ?? '',
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
