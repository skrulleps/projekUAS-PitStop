import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'package:intl/intl.dart';
import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/utils/admin_utils.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DateTime selectedDate = DateTime.now();

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
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final nextDays = _adminUtils.getNext6DaysExcludingFriday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: const AdminSidebar(),
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
        ),
      ),
    );
  }
}
