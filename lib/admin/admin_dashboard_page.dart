import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'package:intl/intl.dart';
import 'package:pitstop/admin/booking/model/booking_model.dart';
import 'package:pitstop/admin/booking/booking_service/booking_service.dart';
import 'package:pitstop/admin/data_master/customer/model/customer_model.dart';
import 'package:pitstop/admin/data_master/customer/service/customer_service.dart';
import 'package:pitstop/admin/data_master/mechanic/model/mechanic_model.dart';
import 'package:pitstop/admin/data_master/mechanic/service/mechanic_service.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DateTime selectedDate = DateTime.now();

  final BookingService _bookingService = BookingService();
  final CustomerService _customerService = CustomerService();
  final MechanicService _mechanicService = MechanicService();

  List<BookingModel> _bookingsToday = [];
  List<CustomerModel> _customers = [];
  List<MechanicModel> _mechanics = [];
  Map<String, ServiceModel> _servicesMap = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataForToday();
  }

  Future<void> _fetchDataForToday() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await _bookingService.getBookings();
      print('Fetched bookings: $bookings');
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final bookingsToday = bookings?.where((b) {
            if (b.bookingsDate == null) return false;
            final bookingDateStr =
                DateFormat('yyyy-MM-dd').format(b.bookingsDate!);
            print('Booking date: $bookingDateStr, Today: $todayStr');
            return bookingDateStr == todayStr;
          }).toList() ??
          [];

      print('Filtered bookings for today: $bookingsToday');

      final customers = await _customerService.getCustomers() ?? [];
      final mechanics = await _mechanicService.getMechanics() ?? [];
      final services = await _bookingService.getAllServices() ?? [];
      final servicesMap = {for (var s in services) s.id ?? '': s};

      setState(() {
        _bookingsToday = bookingsToday;
        _customers = customers;
        _mechanics = mechanics;
        _servicesMap = servicesMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data for today: $e');
    }
  }

  String _getCustomerName(String? userId) {
    final customer = _customers.firstWhere((c) => c.usersId == userId,
        orElse: () => CustomerModel(fullName: 'Unknown'));
    return customer.fullName ?? 'Unknown';
  }

  String _getMechanicName(String? mechanicId) {
    final mechanic = _mechanics.firstWhere((m) => m.id == mechanicId,
        orElse: () => MechanicModel(fullName: 'Unknown'));
    return mechanic.fullName ?? 'Unknown';
  }

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
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    flex: 2,
                    child: _buildBookingListForDate(_bookingsToday),
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
                      _buildBookingListForDate([]),
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

  Widget _buildBookingListForDate(List<BookingModel> bookings) {
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
          title: Row(
            children: [
              Text(
                booking.id ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_getCustomerName(booking.usersId)),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${_servicesMap[booking.servicesId]?.serviceName ?? 'Unknown Service'} with ${_getMechanicName(booking.mechanicsId)}'),
              Text('Status: ${booking.status ?? 'Unknown'}'),
            ],
          ),
        );
      },
    );
  }
}
