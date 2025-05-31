import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk DateFormat dan NumberFormat
import 'model/booking_model.dart'; // Sesuaikan path jika perlu
// import 'model/booking_service_model.dart'; // Jika dipakai, pastikan path benar
import 'booking_service/booking_service.dart'; // Sesuaikan path jika perlu
import 'package:pitstop/admin/data_master/service/model/service_model.dart'; // Sesuaikan path jika perlu
// import 'package:pitstop/admin/booking/booking_service/booking_service_extension.dart'; // Jika tidak dipakai, bisa dikomentari/dihapus
import 'package:pitstop/admin/data_master/service/service_service.dart'; // Sesuaikan path jika perlu
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math; // Untuk math.min jika ada substring ID

class EditBookingFormPage extends StatefulWidget {
  final BookingModel booking;

  const EditBookingFormPage({Key? key, required this.booking}) : super(key: key);

  @override
  State<EditBookingFormPage> createState() => _EditBookingFormPageState();
}

class _EditBookingFormPageState extends State<EditBookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final ServiceService _serviceService = ServiceService();
  final SupabaseClient _client = Supabase.instance.client;

  // --- Variabel State (Logika tidak diubah dari kode asli Anda) ---
  String? _selectedUserId;
  String? _selectedMechanicId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _status = 'Pending';
  String? _notes;
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _selectedServices = [];
  double _totalPrice = 0.0;

  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _mechanics = [];

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadProfiles();
    _loadMechanics();
    _loadServices();
    _loadBookingData();
  }

  // --- Semua fungsi _loadData (Logika tidak diubah dari kode asli Anda) ---
  Future<void> _loadProfiles() async {
    final response = await _client.from('profiles').select('id, full_name, users_id');
    if (!mounted) return;
    final uniqueProfilesMap = <String, Map<String, dynamic>>{};
    if (response != null) {
      for (var profile in response as List) {
        final userId = profile['users_id'];
        if (userId != null && !uniqueProfilesMap.containsKey(userId)) {
          uniqueProfilesMap[userId] = profile as Map<String, dynamic>;
        }
      }
    }
    setState(() {
      _profiles = uniqueProfilesMap.values.toList();
    });
  }

  Future<void> _loadMechanics() async {
    final response = await _client.from('mechanics').select('id, full_name, spesialisasi, status').eq('status', 'Active');
    if (!mounted) return;
    setState(() {
      _mechanics = List<Map<String, dynamic>>.from(response as List? ?? []);
    });
  }

  void _loadBookingData() async {
    final booking = widget.booking;
    _selectedUserId = booking.usersId;
    _selectedMechanicId = booking.mechanicsId;
    _selectedDate = booking.bookingsDate;
    if (booking.bookingsTime != null) {
      final parts = booking.bookingsTime!.split(':');
      if (parts.length >= 2) {
        try {
          _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        } catch (e) {
          _selectedTime = null;
        }
      }
    }
    _status = booking.status ?? 'Pending';
    _notes = booking.notes;
    // Pastikan _totalPrice adalah double
    if (widget.booking.totalPrice is String) {
      _totalPrice = double.tryParse(widget.booking.totalPrice as String) ?? 0.0;
    } else if (widget.booking.totalPrice is num) {
      _totalPrice = (widget.booking.totalPrice as num).toDouble();
    } else {
      _totalPrice = 0.0;
    }

    await _loadSelectedServices();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSelectedServices() async {
    if (_selectedUserId == null) {
      if (!mounted) return;
      setState(() { _selectedServices = []; });
      return;
    }
    final servicesData = await _bookingService.getServicesByUserId(_selectedUserId!);
    if (!mounted) return;
    setState(() {
      _selectedServices = servicesData ?? [];
    });
  }

  Future<void> _loadServices() async {
    final servicesData = await _serviceService.getServices();
    if (!mounted) return;
    setState(() {
      _allServices = servicesData ?? [];
    });
  }

  // --- Fungsi _saveBooking (Dengan catatan TODO untuk perbaikan service call) ---
  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() { _isSaving = true; });

    bool success = false;

    if (_selectedUserId != null) {
      // !!! PERHATIAN PENTING !!! (Catatan TODO sama seperti sebelumnya)
      // Metode 'updateStatusByUserId' TIDAK DITEMUKAN di BookingService Anda.
      // Anda PERLU MENGGANTINYA dengan metode yang BENAR dari BookingService Anda.
      // success = await _bookingService.updateStatusByUserId(_selectedUserId!, _status); // <--- BARIS ASLI YANG ERROR

      // TODO: GANTI BARIS DI ATAS DENGAN PEMANGGILAN FUNGSI SERVICE YANG BENAR
      print("SIMULASI PENYIMPANAN: Panggil BookingService yang benar di sini untuk update status '$_status'.");
      await Future.delayed(const Duration(seconds: 1));
      success = false; // Ganti ke true jika ingin tes alur sukses UI saja
    } else {
      print("Tidak bisa menyimpan: User ID tidak terpilih.");
    }

    if (!mounted) return;
    setState(() { _isSaving = false; });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Status booking berhasil diperbarui!'),
        backgroundColor: Colors.green, duration: Duration(seconds: 2),
      ));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal memperbarui status booking. Periksa implementasi penyimpanan Anda.'),
        backgroundColor: Colors.white, duration: Duration(seconds: 3),
      ));
    }
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {bool isMoney = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text("$label: ", style: TextStyle(fontSize: 14.5, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(fontSize: 14.5, fontWeight: isMoney ? FontWeight.bold : FontWeight.normal, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dateText = _selectedDate != null ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate!) : 'Belum diatur';
    final String timeText = _selectedTime != null ? _selectedTime!.format(context) : 'Belum diatur';

    // Pastikan nama field di Map/Model Anda sudah benar di sini
    final userName = _profiles.firstWhere((p) => p['users_id'] == _selectedUserId, orElse: () => {'full_name': 'Customer tidak ditemukan'})['full_name'] ?? 'Customer tidak ditemukan';
    final mechanicName = _mechanics.firstWhere((m) => m['id'] == _selectedMechanicId, orElse: () => {'full_name': 'Mekanik tidak ditemukan'})['full_name'] ?? 'Mekanik tidak ditemukan';
    final String bookingIdShort = widget.booking.id != null && widget.booking.id!.length > 8 ? widget.booking.id!.substring(0,8) : (widget.booking.id ?? "N/A");

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Booking #${bookingIdShort}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          children: [
            Card( // Card 1: Rincian Booking
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Rincian Booking", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    const Divider(height: 24, thickness: 0.5),
                    _buildDetailRow(context, Icons.person_pin_circle_outlined, "Customer", userName),
                    _buildDetailRow(context, Icons.construction_rounded, "Mekanik", mechanicName),
                    _buildDetailRow(context, Icons.calendar_month_rounded, "Tanggal", dateText),
                    _buildDetailRow(context, Icons.access_time_filled_rounded, "Waktu", timeText),
                    if (_notes != null && _notes!.isNotEmpty) ...[
                      const Divider(height: 20, thickness: 0.3, indent: 8, endIndent: 8),
                      _buildDetailRow(context, Icons.sticky_note_2_outlined, "Catatan", _notes!),
                    ]
                  ],
                ),
              ),
            ),

            Card( // Card 2: Jasa Servis & Total Harga
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jasa Servis Dipesan", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    const Divider(height: 24, thickness: 0.5),
                    if (_selectedServices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: Text("Tidak ada jasa servis yang tercatat.", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic))),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedServices.length,
                        itemBuilder: (context, index) {
                          final service = _selectedServices[index];

                          // !!! PERBAIKAN UNTUK HARGA YANG MUNGKIN STRING !!!
                          num priceValue = 0;
                          if (service.price != null) {
                            if (service.price is String) {
                              priceValue = double.tryParse(service.price as String) ?? 0;
                            } else if (service.price is num) {
                              priceValue = service.price as num;
                            }
                          }
                          // !!! AKHIR PERBAIKAN HARGA !!!

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.settings_suggest_outlined, color: Theme.of(context).colorScheme.secondary, size: 22),
                                const SizedBox(width: 12),
                                Expanded(child: Text(service.serviceName ?? 'Layanan tidak bernama', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                                Text(
                                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(priceValue), // Gunakan priceValue
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: Colors.black87),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(height: 16, thickness: 0.3),
                      ),
                    const Divider(height: 28, thickness: 0.8, color: Colors.black38),
                    _buildDetailRow(context, Icons.monetization_on_outlined, "Total Estimasi Harga",
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalPrice), // _totalPrice sudah double
                      isMoney: true,
                    ),
                  ],
                ),
              ),
            ),

            Card( // Card 3: Update Status
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ubah Status Booking", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        labelText: 'Pilih Status Baru',
                        hintText: 'Pilih status booking',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.published_with_changes_rounded, color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                      ),
                      items: <String>['Pending', 'Confirmed', 'On Progress', 'Done', 'Cancelled']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() { _status = newValue ?? _status; });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) { return 'Status tidak boleh kosong'; }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding( // Tombol Update
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton.icon(
                icon: _isSaving ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).colorScheme.onPrimary)) : const Icon(Icons.save_as_outlined, size: 20),
                label: Text(_isSaving ? 'Menyimpan...' : 'Update Status Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _saveBooking,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}