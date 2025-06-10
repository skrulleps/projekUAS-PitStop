import 'package:flutter/material.dart';
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'package:pitstop/admin/booking/booking_form.dart';
import 'package:pitstop/admin/booking/edit_booking_form.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import '../../data/model/booking/booking_model.dart';
import '../../data/api/booking/booking_service.dart';
import '../../data/api/booking/booking_service_extension.dart';
import 'booking_print/booking_print_service.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';
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
  final Map<String, BookingModel> groupedBookings = {};

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

    // Debug prints to verify customers list and booking usersId values
    if (customersData != null) {
      print('DEBUG: Customers list:');
      for (var c in customersData) {
        print('Customer usersId: \${c.usersId}, fullName: \${c.fullName}');
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
     final Map<String, BookingModel> groupedBookings = {};
    if (bookings != null) {
      for (var booking in bookings) {
        final key =
            '${booking.bookingsDate?.toIso8601String().split("T")[0]}_${booking.bookingsTime}';
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
      MaterialPageRoute(
          builder: (_) => EditBookingFormPage(
                booking: booking,
              )),
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
          const SnackBar(content: Text('Booking berhasil dihapus')),
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
        content: const Text(
            'Apakah Anda yakin ingin menghapus semua booking dengan tanggal dan waktu yang sama?'),
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
          const SnackBar(
              content: Text(
                  'Semua booking dengan tanggal dan waktu yang sama berhasil dihapus')),
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
        backgroundColor: Colors.black, // Background hitam
        title: const Text(
          'Daftar Booking',
          style: TextStyle(color: Colors.amber), // Judul amber
        ),
        iconTheme: const IconThemeData(color: Colors.amber), // Warna ikon amber
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Print Bookings',
            onPressed: () async {
              if (_filteredBookings.isNotEmpty) {
                final bookingPrintService = BookingPrintService();

                Map<String, String> userFullNamesById = {
                  for (var c in customers) c.usersId ?? '': c.fullName ?? '-'
                };
                Map<String, String> mechanicFullNamesById = {
                  for (var m in mechanics) m.id ?? '': m.fullName ?? '-'
                };

                Map<String, List<ServiceModel>> serviceListByUserId = {};
                for (var booking in _filteredBookings) {
                  final userId = booking.usersId!;
                  final dateStr = booking.bookingsDate != null
                      ? booking.bookingsDate!.toIso8601String().split('T')[0]
                      : '';
                  final timeStr = booking.bookingsTime ?? '';
                  final compositeKey = '${userId}_$dateStr\_$timeStr';
                  if (!serviceListByUserId.containsKey(compositeKey)) {
                    final servicesList =
                        await _bookingService.getServicesByUserIdAndDateTime(
                      userId,
                      booking.bookingsDate,
                      booking.bookingsTime,
                    );
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
          child: Container(
            color: Colors.black, // background hitam juga di bawah dropdown
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButton<String>(
              dropdownColor: Colors.black, // warna dropdown hitam
              value: _selectedStatus ?? 'All',
              isExpanded: true,
              onChanged: _onStatusChanged,
              style: const TextStyle(
                  color: Colors.amber), // teks amber di dropdown
              items: statusOptions
                  .map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _filteredBookings.isEmpty
        ? const Center(
            child: Text(
              'Belum ada data booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          )
        : ListView.builder(
            itemCount: _filteredBookings.length,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemBuilder: (context, index) {
              final booking = _filteredBookings[index];

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

              // Status colors
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => _navigateToEdit(booking),
                        tooltip: 'Edit Booking',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent),
                        onPressed: () {
                          if (booking.bookingsDate != null &&
                              booking.bookingsTime != null) {
                            _deleteBookingsByDateTime(
                              booking.bookingsDate!,
                              booking.bookingsTime!,
                            );
                          }
                        },
                        tooltip: 'Delete Booking',
                      ),
                    ],
                  ),
                  onTap: () async {
                    final services = await _bookingService
                        .getServicesByUserIdAndDateTime(
                            booking.usersId ?? '',
                            booking.bookingsDate,
                            booking.bookingsTime);
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
                ),
              );
            },
          ),

    );
  }
}
