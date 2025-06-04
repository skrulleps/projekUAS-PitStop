import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'package:intl/intl.dart';
<<<<<<< HEAD
import 'package:pitstop/admin/booking/model/booking_model.dart';
import 'package:pitstop/admin/data_master/customer/model/customer_model.dart';
import 'package:pitstop/admin/data_master/mechanic/model/mechanic_model.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import 'package:pitstop/utils/admin_utils.dart';
=======
>>>>>>> view2

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DateTime selectedDate = DateTime.now();

<<<<<<< HEAD
  final AdminUtils _adminUtils = AdminUtils();

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
      final data = await _adminUtils.fetchDataForToday();

      setState(() {
        _bookingsToday = data['bookingsToday'] as List<BookingModel>;
        _customers = data['customers'] as List<CustomerModel>;
        _mechanics = data['mechanics'] as List<MechanicModel>;
        _servicesMap = data['servicesMap'] as Map<String, ServiceModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data for today: $e');
    }
=======
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
>>>>>>> view2
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
<<<<<<< HEAD
    final nextDays = _adminUtils.getNext6DaysExcludingFriday();
=======
    final nextDays = getNext6DaysExcludingFriday();
>>>>>>> view2

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: const AdminSidebar(),
<<<<<<< HEAD
      body: RefreshIndicator(
        onRefresh: _fetchDataForToday,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Text(
                  'Bookings for Today (${dateFormat.format(DateTime.now())})',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        height: 200,
                        child: Scrollbar(
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              FutureBuilder<Map<String, List<ServiceModel>>>(
                                future: _adminUtils.fetchServicesForBookings(_bookingsToday),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    final servicesByBookingId = snapshot.data ?? {};
                                    return _adminUtils.buildBookingListForDate(
                                      _bookingsToday,
                                      _customers,
                                      _mechanics,
                                      _servicesMap,
                                      servicesByBookingId,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                Text(
                  'Bookings for Next 6 Days (excluding Friday)',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: nextDays.length,
                    itemBuilder: (context, index) {
                      final day = nextDays[index];
                      return ExpansionTile(
                        title: Text(dateFormat.format(day)),
                        children: [
                          _adminUtils.buildBookingListForDate(
                            [],
                            _customers,
                            _mechanics,
                            _servicesMap,
                            {},
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
=======
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
>>>>>>> view2
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

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
>>>>>>> view2
}
