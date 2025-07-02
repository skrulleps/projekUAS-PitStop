import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/data/api/booking/booking_service.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/api/booking/booking_service_extension.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';
import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';
import 'package:pitstop/home/booking_detail_page.dart';
import 'booking_add_page.dart';
import 'profile_page.dart';

class BookingPage extends StatefulWidget {
  final VoidCallback? onRequestProfileTab;

  const BookingPage({Key? key, this.onRequestProfileTab}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  final CustomerService _customerService = CustomerService();
  final MechanicService _mechanicService = MechanicService();
  

  List<BookingModel> _bookings = [];
  List<CustomerModel> _customers = [];
  List<MechanicModel> _mechanics = [];
  Map<String, List<ServiceModel>> _servicesByGroup = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final bookings = await _bookingService.getBookings();
    final customers = await _customerService.getCustomers();
    final mechanics = await _mechanicService.getMechanics();

    // Debug prints to verify customers and bookings data
    if (customers != null) {
      print('DEBUG: Customers list:');
      for (var c in customers) {
        print('Customer usersId: ${c.usersId}, fullName: ${c.fullName}');
      }
    } else {
      print('DEBUG: Customers list is null');
    }
    if (bookings != null) {
      print('DEBUG: Booking usersId values:');
      for (var b in bookings) {
        print('Booking usersId: ${b.usersId}');
      }
    } else {
      print('DEBUG: Bookings list is null');
    }

    Map<String, BookingModel> groupedBookings = {};
    Map<String, List<ServiceModel>> servicesByGroup = {};

    if (bookings != null) {
      for (var booking in bookings) {
        String bookingDate = booking.bookingsDate != null
            ? booking.bookingsDate!.toIso8601String().split('T')[0]
            : '-';
        String bookingTime = booking.bookingsTime ?? '-';
        String key = '$bookingDate|$bookingTime';

        if (!groupedBookings.containsKey(key)) {
          groupedBookings[key] = booking;

          // Fetch services for this booking group
          final services = await _bookingService.getServicesByUserIdAndDateTime(
            booking.usersId ?? '',
            booking.bookingsDate,
            booking.bookingsTime,
          );
          if (services != null) {
            servicesByGroup[key] = services;
          }
        }
      }
    }

    setState(() {
      _bookings = groupedBookings.values.toList();
      _customers = customers ?? [];
      _mechanics = mechanics ?? [];
      _servicesByGroup = servicesByGroup;
      _isLoading = false;
    });
  }

  String _getUserName(String? userId) {
    final user = _customers.firstWhere((u) => u.usersId == userId, orElse: () => CustomerModel(usersId: '', fullName: 'Unknown'));
    return user.fullName ?? 'Unknown';
  }

  String _getMechanicName(String? mechanicId) {
    final mechanic = _mechanics.firstWhere((m) => m.id == mechanicId, orElse: () => MechanicModel(id: '', fullName: 'Unknown'));
    return mechanic.fullName ?? 'Unknown';
  }

  List<BookingModel> _filterBookingsByStatusAndUser(String status, String userId) {
    return _bookings.where((booking) {
      final bookingStatus = booking.status?.toLowerCase();
      final bookingUserId = booking.usersId ?? '';
      if (userId.isEmpty) return false;
      switch (status) {
        case 'Pending':
          return (bookingStatus == 'pending' || bookingStatus == 'Pending') && bookingUserId == userId;
        case 'OnGoing':
          return bookingStatus == 'on progress' && bookingUserId == userId;
        case 'Completed':
          return bookingStatus == 'done' && bookingUserId == userId;
        case 'Canceled':
          return bookingStatus == 'cancelled' && bookingUserId == userId;
        default:
          return false;
      }
    }).toList();
  }
  
  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Anda Belum Booking',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    List<BookingModel> filteredBookings = bookings;

    List<String> sortedKeys = filteredBookings.map((b) {
      String bookingDate = b.bookingsDate != null
          ? b.bookingsDate!.toLocal().toIso8601String().split('T')[0]
          : '-';
      String bookingTime = b.bookingsTime ?? '-';
      return '$bookingDate|$bookingTime';
    }).toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    Color getStatusBgColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'pending':
          return Colors.amber.withOpacity(0.15);
        case 'on progress':
          return Colors.amber.withOpacity(0.25);
        case 'confirmed':
          return Colors.amber.shade100;
        case 'done':
          return Colors.black12;
        case 'cancelled':
          return Colors.red.withOpacity(0.2);
        default:
          return Colors.transparent;
      }
    }

    Color getStatusTextColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'pending':
        case 'on progress':
        case 'confirmed':
          return Colors.amber.shade800;
        case 'done':
          return Colors.black87;
        case 'cancelled':
          return Colors.red.shade700;
        default:
          return Colors.black87;
      }
    }

    return ListView.builder(
      itemCount: sortedKeys.length,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemBuilder: (context, index) {
        String key = sortedKeys[index];
        BookingModel booking = filteredBookings.firstWhere((b) {
          String bookingDate = b.bookingsDate != null
              ? b.bookingsDate!.toLocal().toIso8601String().split('T')[0]
              : '-';
          String bookingTime = b.bookingsTime ?? '-';
          return key == '$bookingDate|$bookingTime';
        });

        String bookingDate = key.split('|')[0];
        String bookingTime = key.split('|')[1];

        String userFullName = _customers.firstWhere(
          (u) => u.usersId == booking.usersId,
          orElse: () => CustomerModel(usersId: '', fullName: 'Unknown'),
        ).fullName ?? 'Unknown';

        String mechanicFullName = _mechanics.firstWhere(
          (m) => m.id == booking.mechanicsId,
          orElse: () => MechanicModel(id: '', fullName: 'Unknown'),
        ).fullName ?? 'Unknown';

        List<ServiceModel> services = _servicesByGroup[key] ?? [];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              userFullName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mechanic: $mechanicFullName',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        bookingDate,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        bookingTime,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusBgColor(booking.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.status ?? '-',
                          style: TextStyle(
                            color: getStatusTextColor(booking.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () async {
              // Debug prints for usersId and mechanicsId
              print('Booking usersId: ${booking.usersId}');
              print('Booking mechanicsId: ${booking.mechanicsId}');

              final profilesList = _customers.map((c) => {
                'users_id': c.usersId,
                'full_name': c.fullName,
              }).toList();
              final mechanicsList = _mechanics.map((m) => {
                'id': m.id,
                'full_name': m.fullName,
              }).toList();

              print('Profiles list passed: $_customers');
              print('Mechanics list passed: $_mechanics');

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingDetailPage(
                    booking: booking,
                    services: services,
                    profiles: _customers,
                    mechanics: _mechanics,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Booking',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber.shade800,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.amber.shade800,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'OnGoing'),
            Tab(text: 'Completed'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoadSuccess) {
                  final userId = state.userId ?? '';
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingList(_filterBookingsByStatusAndUser('Pending', userId)),
                      _buildBookingList(_filterBookingsByStatusAndUser('OnGoing', userId)),
                      _buildBookingList(_filterBookingsByStatusAndUser('Completed', userId)),
                      _buildBookingList(_filterBookingsByStatusAndUser('Canceled', userId)),
                    ],
                  );
                } else {
                  return const Center(child: Text('User not logged in'));
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final userState = context.read<UserBloc>().state;
          if (userState is UserLoadSuccess) {
            // Find the current user's fullName from _customers
            final currentUser = _customers.firstWhere(
              (customer) => customer.usersId == userState.userId,
              orElse: () => CustomerModel(usersId: '', fullName: ''),
            );

            final fullName = currentUser.fullName ?? '';

            if (fullName.isEmpty) {
              // Show alert dialog and navigate to ProfilePage
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profile Incomplete'),
                  content: const Text('Please complete your profile before adding a booking.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              // Navigate to ProfilePage for editing
              if (widget.onRequestProfileTab != null) {
                widget.onRequestProfileTab!();
              }
            } else {
              // Proceed to BookingAddPage
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingAddPage(
                    userId: userState.userId,
                    userFullName: fullName,
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  _fetchData();
                }
              });
            }
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.amber.shade800,
      ),
    );
  }
}