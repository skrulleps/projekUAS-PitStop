import 'package:flutter/material.dart';
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'package:pitstop/admin/booking/booking_form.dart';
import 'package:pitstop/admin/booking/edit_booking_form.dart';
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import 'model/booking_model.dart';
import 'booking_service/booking_service.dart';
import 'booking_service/booking_service_extension.dart';
import 'booking_service/booking_print_service.dart';
import 'package:pitstop/admin/data_master/customer/service/customer_service.dart';
import 'package:pitstop/admin/data_master/mechanic/service/mechanic_service.dart';
import 'package:pitstop/admin/data_master/service/service_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _bookingService = BookingService();
  final CustomerService _customerService = CustomerService();
  final MechanicService _mechanicService = MechanicService();
  final ServiceService _serviceService = ServiceService();

  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  List customers = [];
  List mechanics = [];
  List services = [];
  bool _isLoading = true;

  String? _selectedStatus;

  BookingModel? _findBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
    });
    final bookings = await _bookingService.getBookings();
    final customersData = await _customerService.getCustomers();
    final mechanicsData = await _mechanicService.getMechanics();
    final servicesData = await _serviceService.getServices();

    // Group bookings by users_id to show only one ListTile per users_id
    final Map<String, BookingModel> groupedBookings = {};
    if (bookings != null) {
      for (var booking in bookings) {
        final key = '${booking.bookingsDate?.toIso8601String().split("T")[0]}_${booking.bookingsTime}';
        if (!groupedBookings.containsKey(key)) {
          groupedBookings[key] = booking;
        }
      }
    }
    setState(() {
      _bookings = groupedBookings.values.toList();
      customers = customersData ?? [];
      mechanics = mechanicsData ?? [];
      services = servicesData ?? [];
      _isLoading = false;
    });
    _applyFilters();
  }

  void _navigateToAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookingFormPage()),
    );
    if (result == true) {
      _fetchAllData();
    }
  }

  void _applyFilters() {
    setState(() {
      List<BookingModel> filtered = _bookings;

      // Filter by status
      if (_selectedStatus != null && _selectedStatus != 'All') {
        filtered = filtered
            .where((booking) =>
                booking.status?.toLowerCase() == _selectedStatus?.toLowerCase())
            .toList();
      }

      _filteredBookings = filtered;
    });
  }

  void _onStatusChanged(String? newStatus) {
    _selectedStatus = newStatus;
    _applyFilters();
  }

  void _navigateToEdit(BookingModel booking) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditBookingFormPage(booking: booking)),
    );
    if (result == true) {
      _fetchAllData();
    }
  }

  void _navigateToDetail(BookingModel booking) {
    // TODO: implement navigation to booking detail page
  }

  Future<void> _deleteBooking(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus booking ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Cari booking berdasarkan id untuk dapatkan users_id
      BookingModel? booking;
      try {
        booking = _bookings.firstWhere((b) => b.id == id);
      } catch (e) {
        booking = null;
      }
      if (booking == null || booking.usersId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking tidak ditemukan')),
        );
        return;
      }
      // Hapus booking berdasarkan id
      final success = await _bookingService.deleteBooking(booking.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking berhasil dihapus')),
        );
        _fetchAllData();
      } else {
        debugPrint('Gagal menghapus booking');
        _fetchAllData();
      }
    }
  }

  Future<void> _deleteBookingsByDateTime(DateTime date, String time) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua booking dengan tanggal dan waktu yang sama?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _bookingService.deleteByDateAndTime(date, time);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua booking dengan tanggal dan waktu yang sama berhasil dihapus')),
        );
        _fetchAllData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus booking')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = <String>[
      'All',
      'Pending',
      'On Progress',
      'Confirmed',
      'Done',
      'Cancelled',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Print Bookings',
            onPressed: () async {
              if (_filteredBookings.isNotEmpty) {
                final bookingPrintService = BookingPrintService();

                // Prepare maps for user full names and mechanic full names
                Map<String, String> userFullNamesById = {
                  for (var c in customers) c.usersId ?? '': c.fullName ?? '-'
                };
                Map<String, String> mechanicFullNamesById = {
                  for (var m in mechanics) m.id ?? '': m.fullName ?? '-'
                };

                // Prepare map for userId to list of service models filtered by date and time
                Map<String, List<ServiceModel>> serviceListByUserId = {};
                for (var booking in _filteredBookings) {
                  final userId = booking.usersId!;
                  final dateStr = booking.bookingsDate != null ? booking.bookingsDate!.toIso8601String().split('T')[0] : '';
                  final timeStr = booking.bookingsTime ?? '';
                  final compositeKey = '${userId}_$dateStr\_$timeStr';
                  if (!serviceListByUserId.containsKey(compositeKey)) {
                    final servicesList = await _bookingService.getServicesByUserIdAndDateTime(userId, booking.bookingsDate, booking.bookingsTime);
                    if (servicesList != null) {
                      serviceListByUserId[compositeKey] = servicesList;
                    }
                  }
                }

                print('DEBUG: serviceListByUserId: $serviceListByUserId');
                await bookingPrintService.printBookings(
                  _filteredBookings,
                  userFullNamesById,
                  mechanicFullNamesById,
                  serviceListByUserId,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAdd,
          ),
        ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButton<String>(
            value: _selectedStatus ?? 'All',
            isExpanded: true,
            onChanged: _onStatusChanged,
            items: statusOptions
                .map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
          ),
        ),
      ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBookings.isEmpty
              ? const Center(child: Text('Belum ada data booking'))
              : ListView.builder(
                  itemCount: _filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _filteredBookings[index];

                    // Prepare maps for user and mechanic full names
                    Map<String, String> userFullNamesById = {
                      for (var c in customers)
                        c.usersId ?? '': c.fullName ?? '-'
                    };
                    Map<String, String> mechanicFullNamesById = {
                      for (var m in mechanics) m.id ?? '': m.fullName ?? '-'
                    };

                    final userFullName =
                        userFullNamesById[booking.usersId] ?? '-';
                    final mechanicFullName =
                        mechanicFullNamesById[booking.mechanicsId] ?? '-';
                    final bookingDate = booking.bookingsDate != null
                        ? '${booking.bookingsDate!.toLocal().toIso8601String().split("T")[0]}'
                        : '-';
                    final bookingTime = booking.bookingsTime ?? '-';

                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userFullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Mechanic : $mechanicFullName'),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 4),
                              Text(bookingDate),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(bookingTime),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: booking.status?.toLowerCase() ==
                                          'pending'
                                      ? Colors.yellow.withOpacity(0.2)
                                      : booking.status?.toLowerCase() ==
                                              'on progress'
                                          ? Colors.orange.withOpacity(0.2)
                                          : booking.status?.toLowerCase() ==
                                                  'confirmed'
                                              ? Colors.blue.withOpacity(0.2)
                                              : booking.status?.toLowerCase() ==
                                                      'done'
                                                  ? Colors.green
                                                      .withOpacity(0.2)
                                                  : booking.status
                                                              ?.toLowerCase() ==
                                                          'cancelled'
                                                      ? Colors.red
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  booking.status ?? '-',
                                  style: TextStyle(
                                    color: booking.status?.toLowerCase() ==
                                            'pending'
                                        ? Colors.yellow[800]
                                        : booking.status?.toLowerCase() ==
                                                'on progress'
                                            ? Colors.orange
                                            : booking.status?.toLowerCase() ==
                                                    'confirmed'
                                                ? Colors.blue
                                                : booking.status
                                                            ?.toLowerCase() ==
                                                        'done'
                                                    ? Colors.green
                                                    : booking.status
                                                                ?.toLowerCase() ==
                                                            'cancelled'
                                                        ? Colors.red
                                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToEdit(booking),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              if (booking.bookingsDate != null && booking.bookingsTime != null) {
                                _deleteBookingsByDateTime(booking.bookingsDate!, booking.bookingsTime!);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                      final services = await _bookingService
                          .getServicesByUserIdAndDateTime(booking.usersId ?? '', booking.bookingsDate, booking.bookingsTime);
                      if (services != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingDetailFormPage(
                              booking: booking,
                              services: services,
                              profiles: customers
                                  .map((c) => {
                                        'users_id': c.usersId,
                                        'full_name': c.fullName,
                                      })
                                  .toList(),
                              mechanics: mechanics
                                  .map((m) => {
                                        'id': m.id,
                                        'full_name': m.fullName,
                                      })
                                  .toList(),
                            ),
                          ),
                        );
                      }
                      },
                    );
                  },
                ),
    );
  }
}
