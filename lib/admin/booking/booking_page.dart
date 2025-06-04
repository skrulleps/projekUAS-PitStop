import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'package:pitstop/admin/booking/booking_form.dart';
import 'package:pitstop/admin/booking/edit_booking_form.dart';
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import 'model/booking_model.dart';
=======
import 'dart:math' as math; // Untuk math.min

// Sesuaikan path import ini dengan struktur proyek Anda
import 'package:pitstop/admin/booking/booking_detail_form.dart';
import 'package:pitstop/admin/booking/booking_form.dart';
import 'package:pitstop/admin/booking/edit_booking_form.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import 'model/booking_model.dart'; // PASTIKAN PATH MODEL BOOKING ANDA BENAR
>>>>>>> view2
import 'booking_service/booking_service.dart';
import 'booking_service/booking_service_extension.dart';
import 'booking_service/booking_print_service.dart';
import 'package:pitstop/admin/data_master/customer/service/customer_service.dart';
import 'package:pitstop/admin/data_master/mechanic/service/mechanic_service.dart';
import 'package:pitstop/admin/data_master/service/service_service.dart';

<<<<<<< HEAD
=======
// Ini adalah class utama StatefulWidget Anda
>>>>>>> view2
class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

<<<<<<< HEAD
class _BookingPageState extends State<BookingPage> {
=======
class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  // --- Variabel State (SAMA SEPERTI KODE ASLI ANDA + TabController) ---
>>>>>>> view2
  final BookingService _bookingService = BookingService();
  final CustomerService _customerService = CustomerService();
  final MechanicService _mechanicService = MechanicService();
  final ServiceService _serviceService = ServiceService();

  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
<<<<<<< HEAD
  List customers = [];
  List mechanics = [];
  List services = [];
  bool _isLoading = true;

  String? _selectedStatus;

=======
  List customers = []; // Akan diisi dari _customerService.getCustomers()
  List mechanics = []; // Akan diisi dari _mechanicService.getMechanics()
  List services = [];  // Akan diisi dari _serviceService.getServices()
  bool _isLoading = true;

  String? _selectedStatus = 'All';
  late TabController _tabController;

  // Daftar status dan label untuk Tab
  final List<String> _tabStatuses = ['All', 'Pending', 'On Progress', 'Confirmed', 'Done', 'Cancelled'];
  final List<String> _tabLabels = ['All', 'Pending', 'In Progress', 'Confirmed', 'Done', 'Canceled'];

  @override
  void initState() {
    super.initState();
    int initialIndex = _tabStatuses.indexOf(_selectedStatus ?? 'All');
    if (initialIndex == -1) initialIndex = 0;

    _tabController = TabController(length: _tabStatuses.length, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        final newStatusForTab = _tabStatuses[_tabController.index];
        if (_selectedStatus != newStatusForTab) {
          _onStatusChanged(newStatusForTab);
        }
      }
    });
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- SEMUA FUNGSI LOGIKA ASLI ANDA TETAP SAMA ---
>>>>>>> view2
  BookingModel? _findBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

<<<<<<< HEAD
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
=======
  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    final bookingsData = await _bookingService.getBookings();
    final customersData = await _customerService.getCustomers(); // Mengambil list customer
    final mechanicsData = await _mechanicService.getMechanics(); // Mengambil list mekanik
    final servicesData = await _serviceService.getServices();

    final Map<String, BookingModel> uniqueBookings = {};
    if (bookingsData != null) {
      for (var booking in bookingsData) {
        final userIdPart = booking.usersId ?? "unknownUser";
        final datePart = booking.bookingsDate?.toIso8601String().split("T")[0] ?? "unknownDate";
        final key = '${userIdPart}_${datePart}';
        if (!uniqueBookings.containsKey(key)) {
          uniqueBookings[key] = booking;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _bookings = uniqueBookings.values.toList();
      customers = customersData ?? []; // Simpan list customer ke state
      mechanics = mechanicsData ?? []; // Simpan list mekanik ke state
>>>>>>> view2
      services = servicesData ?? [];
      _isLoading = false;
    });
    _applyFilters();
  }

<<<<<<< HEAD
=======
  void _applyFilters() {
    if (!mounted) return;
    setState(() {
      List<BookingModel> filtered = List.from(_bookings);
      if (_selectedStatus != null && _selectedStatus != 'All') {
        filtered = filtered.where((booking) =>
        booking.status?.toLowerCase() == _selectedStatus?.toLowerCase()).toList();
      }
      _filteredBookings = filtered;
    });
  }

  void _onStatusChanged(String? newStatus) {
    if (!mounted) return;
    setState(() { _selectedStatus = newStatus; });
    _applyFilters();
  }

>>>>>>> view2
  void _navigateToAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookingFormPage()),
    );
<<<<<<< HEAD
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
=======
    if (result == true && mounted) { _fetchAllData(); }
>>>>>>> view2
  }

  void _navigateToEdit(BookingModel booking) async {
    final result = await Navigator.of(context).push(
<<<<<<< HEAD
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
=======
      MaterialPageRoute(builder: (_) => EditBookingFormPage(booking: booking)),
    );
    if (result == true && mounted) { _fetchAllData(); }
  }

  void _navigateToActualDetail(BookingModel booking) async {
    final servicesForDetail = await _bookingService.getServicesByUserId(booking.usersId ?? '');
    if (!mounted) return;
    if (servicesForDetail != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingDetailFormPage(
            booking: booking,
            services: servicesForDetail,
            profiles: customers.map((c) {
              // PASTIKAN FIELD 'users_id' DAN 'full_name' SESUAI MODEL CUSTOMER ANDA
              return {'users_id': c.usersId, 'full_name': c.fullName};
            }).toList(),
            mechanics: mechanics.map((m) {
              // PASTIKAN FIELD 'id' DAN 'full_name' SESUAI MODEL MECHANIC ANDA
              return {'id': m.id, 'full_name': m.fullName};
            }).toList(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat memuat detail layanan.')),
      );
    }
>>>>>>> view2
  }

  Future<void> _deleteBooking(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
<<<<<<< HEAD
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
=======
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus data booking ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
>>>>>>> view2
        ],
      ),
    );

    if (confirmed == true) {
<<<<<<< HEAD
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
=======
      BookingModel? bookingToDelete = _findBookingById(id);
      if (bookingToDelete == null || bookingToDelete.usersId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking tidak ditemukan atau User ID tidak valid.')),
          );
        }
        return;
      }
      final success = await _bookingService.deleteByUserId(bookingToDelete.usersId!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking berhasil dihapus.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus booking.')));
        }
>>>>>>> view2
        _fetchAllData();
      }
    }
  }

<<<<<<< HEAD
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
=======
  // --- FUNGSI _buildBookingCard (FOKUS DI SINI UNTUK PENYESUAIAN NAMA FIELD) ---
  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    String userFullName = "Customer Tidak Ditemukan"; // Default jika tidak ketemu
    if (customers.isNotEmpty && booking.usersId != null) {
      try {
        final customerData = customers.firstWhere(
          // (c) => c.usersId == booking.usersId, // JIKA 'customers' adalah List<CustomerModel>
              (c) => c['users_id'] == booking.usersId, // JIKA 'customers' adalah List<Map<String, dynamic>>
          orElse: () => null,
        );
        if (customerData != null) {
          // userFullName = customerData.fullName ?? "Nama Customer Kosong"; // JIKA 'customers' adalah List<CustomerModel>
          userFullName = customerData['full_name'] ?? "Nama Customer Kosong"; // JIKA 'customers' adalah List<Map<String, dynamic>>
        }
      } catch (e) { /* Gagal mencari customer, biarkan userFullName default */ }
    }

    String mechanicFullName = "Bengkel Tidak Ditemukan"; // Default jika tidak ketemu
    if (mechanics.isNotEmpty && booking.mechanicsId != null) {
      try {
        final mechanicData = mechanics.firstWhere(
          // (m) => m.id == booking.mechanicsId, // JIKA 'mechanics' adalah List<MechanicModel>
              (m) => m['id'] == booking.mechanicsId, // JIKA 'mechanics' adalah List<Map<String, dynamic>>
          orElse: () => null,
        );
        if (mechanicData != null) {
          // mechanicFullName = mechanicData.fullName ?? "Nama Bengkel Kosong"; // JIKA 'mechanics' adalah List<MechanicModel>
          mechanicFullName = mechanicData['full_name'] ?? "Nama Bengkel Kosong"; // JIKA 'mechanics' adalah List<Map<String, dynamic>>
        }
      } catch (e) { /* Gagal mencari mekanik, biarkan mechanicFullName default */ }
    }

    // --- Sisa variabel dan logika warna status sama seperti sebelumnya ---
    final bookingDate = booking.bookingsDate != null
        ? '${booking.bookingsDate!.toLocal().day.toString().padLeft(2, '0')}/${booking.bookingsDate!.toLocal().month.toString().padLeft(2, '0')}/${booking.bookingsDate!.toLocal().year}'
        : '-';
    final bookingTime = booking.bookingsTime ?? '-';
    final bookingStatus = booking.status ?? '-';
    final String bookingIdDisplay = '#${booking.id?.substring(0, math.min(booking.id?.length ?? 0, 8)) ?? 'N/A'}';

    Color statusColor = Colors.grey.withOpacity(0.1);
    Color statusTextColor = Colors.grey[700]!;
    final statusLower = bookingStatus.toLowerCase();
    if (statusLower == 'pending') {
      statusColor = Colors.orange.withOpacity(0.15); statusTextColor = Colors.orange[800]!;
    } else if (statusLower == 'on progress') {
      statusColor = Colors.blue.withOpacity(0.15); statusTextColor = Colors.blue[700]!;
    } else if (statusLower == 'confirmed') {
      statusColor = Colors.teal.withOpacity(0.15); statusTextColor = Colors.teal[700]!;
    } else if (statusLower == 'done') {
      statusColor = Colors.green.withOpacity(0.15); statusTextColor = Colors.green[700]!;
    } else if (statusLower == 'cancelled') {
      statusColor = Colors.red.withOpacity(0.15); statusTextColor = Colors.red[700]!;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.storefront_outlined, size: 36, color: Colors.grey[500]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mechanicFullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.5, color: Colors.grey[850]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text("Alamat tidak tersedia", style: TextStyle(fontSize: 13, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(bookingIdDisplay, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber[600], size: 24),
                    const SizedBox(height: 2),
                    Text("3.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.person_outline_rounded, "Customer:", userFullName),
            _buildDetailRow(Icons.calendar_today_outlined, "Tanggal:", "$bookingDate @ $bookingTime"),
            Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text("Status:", style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6)),
                    child: Text(bookingStatus, style: TextStyle(color: statusTextColor, fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600], foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 1.5,
                ),
                child: const Text("View Detail"),
                onPressed: () => _navigateToActualDetail(booking),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary, size: 22),
                    tooltip: 'Edit Booking',
                    onPressed: () => _navigateToEdit(booking),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 22),
                    tooltip: 'Delete Booking',
                    onPressed: () { if (booking.id != null) _deleteBooking(booking.id!); },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(width: 5),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[850], fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
>>>>>>> view2
          ),
        ],
      ),
    );
<<<<<<< HEAD

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
=======
>>>>>>> view2
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking'),
        actions: [ /* Tombol Aksi AppBar Sama Seperti Sebelumnya */
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
>>>>>>> view2
            tooltip: 'Print Bookings',
            onPressed: () async {
              if (_filteredBookings.isNotEmpty) {
                final bookingPrintService = BookingPrintService();
<<<<<<< HEAD

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
=======
                Map<String, String> userFullNamesById = {
                  for (var c in customers) (c.usersId) ?? '': (c.fullName) ?? '-' // Sesuaikan jika customers adalah Map
                };
                Map<String, String> mechanicFullNamesById = {
                  for (var m in mechanics) (m.id) ?? '': (m.fullName) ?? '-' // Sesuaikan jika mechanics adalah Map
                };
                Map<String, List<ServiceModel>> serviceListByUserId = {};
                for (var booking in _filteredBookings) {
                  final userId = booking.usersId;
                  if (userId != null && !serviceListByUserId.containsKey(userId)) {
                    final servicesList = await _bookingService.getServicesByUserId(userId);
                    if (servicesList != null) { serviceListByUserId[userId] = servicesList; }
                  }
                }
                await bookingPrintService.printBookings(
                    _filteredBookings, userFullNamesById, mechanicFullNamesById, serviceListByUserId);
>>>>>>> view2
              }
            },
          ),
          IconButton(
<<<<<<< HEAD
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
=======
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add Booking',
            onPressed: _navigateToAdd,
          ),
        ],
        bottom: TabBar( /* TabBar Sama Seperti Sebelumnya */
          controller: _tabController,
          isScrollable: true,
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
          indicatorWeight: 2.5,
          indicatorColor: Colors.amber[700],
          labelColor: Colors.amber[800],
          unselectedLabelColor: Colors.grey[600],
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          overlayColor: MaterialStateProperty.all(Colors.amber.withOpacity(0.1)),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!)))
          : _filteredBookings.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Text('Tidak ada data booking untuk status "${_selectedStatus ?? "All"}".', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600]))))
          : ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = _filteredBookings[index];
          return _buildBookingCard(context, booking);
        },
      ),
    );
  }
}
>>>>>>> view2
