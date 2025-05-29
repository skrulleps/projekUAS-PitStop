import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DateTime selectedDate = DateTime.now();

  // Dummy booking data for demonstration
  final Map<String, List<Map<String, String>>> bookingsByDate = {
    // Format: 'yyyy-MM-dd': list of bookings
    '2024-06-03': [
      {'customer': 'John Doe', 'service': 'Oil Change', 'time': '10:00 AM'},
      {'customer': 'Jane Smith', 'service': 'Tire Replacement', 'time': '11:30 AM'},
    ],
    '2024-06-04': [
      {'customer': 'Bob Johnson', 'service': 'Brake Inspection', 'time': '02:00 PM'},
    ],
    // Add more dates as needed
  };

  List<DateTime> getNext6DaysExcludingFriday() {
    List<DateTime> days = [];
    DateTime current = DateTime.now();
    int added = 0;
    while (added < 6) {
      current = current.add(const Duration(days: 1));
      if (current.weekday != DateTime.friday) {
        days.add(current);
        added++;
      }
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final nextDays = getNext6DaysExcludingFriday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: const AdminSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Bookings for Today (${dateFormat.format(DateTime.now())})',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: _buildBookingListForDate(DateTime.now()),
            ),
            const SizedBox(height: 16),
            Text(
              'Bookings for Next 6 Days (excluding Friday)',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: nextDays.length,
                itemBuilder: (context, index) {
                  final day = nextDays[index];
                  return ExpansionTile(
                    title: Text(dateFormat.format(day)),
                    children: [
                      _buildBookingListForDate(day),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingListForDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final bookings = bookingsByDate[dateKey] ?? [];

    if (bookings.isEmpty) {
      return const ListTile(
        title: Text('No bookings'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return ListTile(
          title: Text(booking['customer'] ?? ''),
          subtitle: Text('${booking['service']} at ${booking['time']}'),
        );
      },
    );
  }
}
