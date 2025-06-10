import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import 'package:intl/intl.dart';
import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/data/utils/admin_utils.dart';

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
    final nextDays = _adminUtils.getNext5DaysExcludingFriday();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      drawer: const AdminSidebar(),
      body: RefreshIndicator(
        onRefresh: _fetchDataForToday,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bookings for Today',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dateFormat.format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 200,
                        child: Scrollbar(
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: [
                              FutureBuilder<Map<String, List<ServiceModel>>>(
                                future: _adminUtils.fetchServicesForBookings(_bookingsToday, _servicesMap),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                                  } else {
                                    final servicesByBookingId = snapshot.data ?? {};
                                    return _adminUtils.buildGroupedBookingListForDate(
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
                const SizedBox(height: 24),
                Text(
                  'Bookings for Next 5 Days (excluding Friday)',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 400,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: nextDays.length,
                    itemBuilder: (context, index) {
                      final day = nextDays[index];
                      return FutureBuilder<Map<String, dynamic>>(
                        future: _adminUtils.fetchDataForDate(day),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                          } else {
                            final data = snapshot.data ?? {};
                            final bookings = data['bookings'] as List<BookingModel>? ?? [];
                            final customers = data['customers'] as List<CustomerModel>? ?? [];
                            final mechanics = data['mechanics'] as List<MechanicModel>? ?? [];
                            final servicesMap = data['servicesMap'] as Map<String, ServiceModel>? ?? {};

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              child: ExpansionTile(
                                iconColor: Colors.amber,
                                textColor: Colors.black,
                                title: Text(
                                  dateFormat.format(day),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                children: [
                                  SizedBox(
                                    height: 300,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _adminUtils.buildGroupedBookingListForDateByCustomerDateTime(
                                        bookings,
                                        customers,
                                        mechanics,
                                        servicesMap,
                                        {},
                                      ).length,
                                      itemBuilder: (context, index) {
                                        final cards = _adminUtils.buildGroupedBookingListForDateByCustomerDateTime(
                                          bookings,
                                          customers,
                                          mechanics,
                                          servicesMap,
                                          {},
                                        );
                                        return Container(
                                          width: 250,
                                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          child: cards[index],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
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
