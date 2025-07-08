import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/data/api/booking/booking_service.dart';
import 'package:pitstop/data/api/booking/booking_service_extension.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';
import 'package:pitstop/data/model/booking/booking_model.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';
// import 'package:pitstop/data/api/booking/booking_service_extension.dart';
import 'package:pitstop/home/booking_detail_page.dart';
import 'package:pitstop/admin/booking/booking_print/booking_detail_print_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final BookingService _bookingService = BookingService();
  final CustomerService _customerService = CustomerService();
  final MechanicService _mechanicService = MechanicService();
  final BookingDetailPrintService _printService = BookingDetailPrintService();

  List<BookingModel> _bookings = [];
  List<CustomerModel> _customers = [];
  List<MechanicModel> _mechanics = [];
  Map<String, List<ServiceModel>> _servicesByGroup = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final userBloc = context.read<UserBloc>().state;
    String? loggedInUserId;
    if (userBloc is UserLoadSuccess) {
      loggedInUserId = userBloc.userId;
    }

    final bookings = await _bookingService.getBookings();
    final customers = await _customerService.getCustomers();
    final mechanics = await _mechanicService.getMechanics();

    Map<String, BookingModel> groupedBookings = {};
    Map<String, List<ServiceModel>> servicesByGroup = {};

    if (bookings != null && loggedInUserId != null) {
      for (var booking in bookings) {
        if (booking.status?.toLowerCase() == 'done' &&
            booking.usersId == loggedInUserId) {
          String bookingDate = booking.bookingsDate != null
              ? booking.bookingsDate!.toIso8601String().split('T')[0]
              : '-';
          String bookingTime = booking.bookingsTime ?? '-';
          String key = '$bookingDate|$bookingTime';

          if (!groupedBookings.containsKey(key)) {
            groupedBookings[key] = booking;

            final services =
                await _bookingService.getServicesByUserIdAndDateTime(
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
    final user = _customers.firstWhere((u) => u.usersId == userId,
        orElse: () => CustomerModel(usersId: '', fullName: 'Unknown'));
    return user.fullName ?? 'Unknown';
  }

  String _getMechanicName(String? mechanicId) {
    final mechanic = _mechanics.firstWhere((m) => m.id == mechanicId,
        orElse: () => MechanicModel(id: '', fullName: 'Unknown'));
    return mechanic.fullName ?? 'Unknown';
  }

  Widget _buildHistoryList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Belum ada riwayat servis.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    List<String> sortedKeys = bookings
        .map((b) {
          String bookingDate = b.bookingsDate != null
              ? b.bookingsDate!.toLocal().toIso8601String().split('T')[0]
              : '-';
          String bookingTime = b.bookingsTime ?? '-';
          return '$bookingDate|$bookingTime';
        })
        .toSet()
        .toList()
      ..sort((a, b) => a.compareTo(b));

    Color getStatusBgColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'done':
          return Colors.green.withOpacity(0.15);
        default:
          return Colors.transparent;
      }
    }

    Color getStatusTextColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'done':
          return Colors.green.shade800;
        default:
          return Colors.black87;
      }
    }

    return ListView.builder(
      itemCount: sortedKeys.length,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemBuilder: (context, index) {
        String key = sortedKeys[index];
        BookingModel booking = bookings.firstWhere((b) {
          String bookingDate = b.bookingsDate != null
              ? b.bookingsDate!.toLocal().toIso8601String().split('T')[0]
              : '-';
          String bookingTime = b.bookingsTime ?? '-';
          return key == '$bookingDate|$bookingTime';
        });

        String bookingDate = key.split('|')[0];
        String bookingTime = key.split('|')[1];

        String userFullName = _getUserName(booking.usersId);
        String mechanicFullName = _getMechanicName(booking.mechanicsId);
        List<ServiceModel> services = _servicesByGroup[key] ?? [];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.amber),
                        tooltip: 'Cetak Struk',
                        onPressed: () {
                          final userFullName = _getUserName(booking.usersId);
                          final mechanicFullName =
                              _getMechanicName(booking.mechanicsId);
                          _printService.printBookingDetail(
                            booking: booking,
                            services: services,
                            userFullName: userFullName,
                            mechanicFullName: mechanicFullName,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
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

  Color getStatusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'done':
        return Colors.green.withOpacity(0.15);
      default:
        return Colors.transparent;
    }
  }

  Color getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'done':
        return Colors.green.shade800;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Servis'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoadSuccess) {
                  return _buildHistoryList(_bookings);
                } else {
                  return const Center(child: Text('User not logged in'));
                }
              },
            ),
    );
  }
}
