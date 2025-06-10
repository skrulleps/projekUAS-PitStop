import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/data/api/booking/booking_service.dart';
import 'package:pitstop/data/api/account/account_service.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';
import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/model/account/user_account_model.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  final AccountService _accountService = AccountService(Supabase.instance.client);
  final MechanicService _mechanicService = MechanicService();

  List<BookingModel> _bookings = [];
  List<UserAccount> _users = [];
  List<MechanicModel> _mechanics = [];
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
    final users = await _accountService.fetchUsers();
    final mechanics = await _mechanicService.getMechanics();
    setState(() {
      _bookings = bookings ?? [];
      _users = users;
      _mechanics = mechanics ?? [];
      _isLoading = false;
    });
  }

  String _getUserName(String? userId) {
    final user = _users.firstWhere((u) => u.id == userId, orElse: () => UserAccount(id: '', email: '', username: 'Unknown', role: ''));
    return user.username ?? 'Unknown';
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
    return ListView.builder(
      itemCount: bookings.length,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];

        String userFullName = _getUserName(booking.usersId);
        String mechanicFullName = _getMechanicName(booking.mechanicsId);
        String bookingDate = booking.bookingsDate != null
            ? booking.bookingsDate!.toLocal().toIso8601String().split('T')[0]
            : '-';
        String bookingTime = booking.bookingsTime ?? '-';

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

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
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
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.black54),
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
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.black54),
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
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
              // TODO: Implement detail view navigation if needed
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
        onPressed: () {
          // TODO: Implement add booking action
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.amber.shade800,
      ),
    );
  }
}