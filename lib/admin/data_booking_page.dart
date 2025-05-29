import 'package:flutter/material.dart';
import 'admin_sidebar.dart';

class DataBookingPage extends StatelessWidget {
  const DataBookingPage({Key? key}) : super(key: key);

  // Placeholder data for bookings
  final List<Map<String, String>> bookings = const [
    {'customer': 'John Doe', 'date': '2024-06-01', 'service': 'Oil Change'},
    {'customer': 'Jane Smith', 'date': '2024-06-01', 'service': 'Tire Replacement'},
    {'customer': 'Bob Johnson', 'date': '2024-06-01', 'service': 'Brake Inspection'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Booking'),
      ),
      drawer: const AdminSidebar(),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return ListTile(
            title: Text(booking['customer'] ?? ''),
            subtitle: Text('${booking['date']} - ${booking['service']}'),
          );
        },
      ),
    );
  }
}
