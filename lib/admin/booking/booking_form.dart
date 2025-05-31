import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk DateFormat dan NumberFormat
import 'model/booking_model.dart'; // Sesuaikan path jika perlu
// import 'model/booking_service_model.dart'; // Jika dipakai dan pathnya benar
import 'booking_service/booking_service.dart'; // Sesuaikan path jika perlu
import 'package:pitstop/admin/data_master/service/model/service_model.dart'; // Sesuaikan path jika perlu
import 'package:pitstop/admin/data_master/service/service_service.dart'; // Sesuaikan path jika perlu
import 'package:supabase_flutter/supabase_flutter.dart';

import 'model/booking_service_model.dart';
// import 'package:pitstop/admin/booking/booking_service/booking_service_extension.dart'; // Jika tidak dipakai, hapus

class BookingFormPage extends StatefulWidget {
  final BookingModel? booking; // Bisa null jika mode 'Tambah Booking'

  const BookingFormPage({Key? key, this.booking}) : super(key: key);

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final ServiceService _serviceService = ServiceService();
  final SupabaseClient _client = Supabase.instance.client;

  // --- Variabel State (SEMUA LOGIKA ASLI ANDA TETAP SAMA) ---
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

  bool _isLoadingPage = true; // Untuk loading data awal halaman
  bool _isSaving = false;    // Untuk loading saat tombol simpan ditekan

  // Untuk menyimpan daftar booking pada tanggal & mekanik terpilih
  List<BookingModel> _bookingsForSelectedDateAndMechanic = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() { _isLoadingPage = true; });
    await Future.wait([
      _loadProfiles(),
      _loadMechanics(),
      _loadServices(),
    ]);
    if (widget.booking != null) {
      await _loadBookingData(); // Termasuk _loadSelectedServices di dalamnya
    }
    // Jika mode tambah dan sudah ada tanggal & mekanik terpilih (misal dari state sebelumnya jika ada)
    // Maka load juga booking yang sudah ada untuk tanggal & mekanik tsb.
    // Namun, karena ini initState, _selectedDate & _selectedMechanicId biasanya null.
    // _loadBookingsForSelectedDateAndMechanic akan dipanggil saat user memilih tanggal/mekanik.
    if (mounted) {
      setState(() { _isLoadingPage = false; });
    }
  }

  // --- SEMUA FUNGSI _loadData, kalkulasi, dan pemilihan (Logika Asli Anda) ---
  Future<void> _loadProfiles() async {
    final response = await _client.from('profiles').select('id, full_name, users_id');
    if (!mounted) return;
    if (response == null) {
      setState(() { _profiles = []; });
      return;
    }
    final uniqueProfilesMap = <String, Map<String, dynamic>>{};
    for (var profile in response as List) {
      final userId = profile['users_id'];
      if (userId != null && !uniqueProfilesMap.containsKey(userId)) {
        uniqueProfilesMap[userId] = profile as Map<String, dynamic>;
      }
    }
    setState(() { _profiles = uniqueProfilesMap.values.toList(); });
  }

  Future<void> _loadMechanics() async {
    final response = await _client.from('mechanics').select('id, full_name, spesialisasi, status').eq('status', 'Active');
    if (!mounted) return;
    setState(() {
      _mechanics = List<Map<String, dynamic>>.from(response as List? ?? []);
    });
  }

  Future<void> _loadBookingData() async { // Dipanggil hanya jika widget.booking != null
    final booking = widget.booking!;
    _selectedUserId = booking.usersId;
    _selectedMechanicId = booking.mechanicsId;
    _selectedDate = booking.bookingsDate;
    if (booking.bookingsTime != null) {
      final parts = booking.bookingsTime!.split(':');
      if (parts.length >= 2) {
        try {
          _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        } catch(e) { _selectedTime = null; }
      }
    }
    _status = booking.status ?? 'Pending';
    _notes = booking.notes;
    _totalPrice = booking.totalPrice ?? 0.0; // Pastikan ini juga di-handle tipenya jika dari string

    // Untuk mode edit, kita perlu juga memuat service yang sudah dipilih
    // dan booking lain pada tanggal & mekanik tersebut untuk disable time slot.
    await _loadSelectedServices(); // Ambil service yang sudah dipilih untuk booking ini
    await _loadBookingsForSelectedDateAndMechanic(); // Ambil booking lain untuk disable time slot
  }

  Future<void> _loadSelectedServices() async {
    if (widget.booking == null || widget.booking!.id == null) { // Perlu booking ID untuk mode edit
      if(mounted) setState(() { _selectedServices = []; });
      return;
    }
    // Logika asli Anda untuk mengambil service ID dari tabel 'booking_services' (atau serupa)
    // Jika Anda punya tabel pivot booking_services(booking_id, service_id) ini lebih ideal.
    // Kode asli Anda mengambil dari tabel 'booking' berdasarkan banyak field, ini mungkin kurang presisi
    // jika ada booking lain dengan detail serupa. Saya akan asumsikan Anda punya cara mengambil service IDs untuk booking ID tertentu.
    // Untuk contoh, saya akan gunakan _bookingService.getServicesByBookingId(widget.booking!.id!) jika ada.
    // Jika tidak, logika asli Anda:
    // final response = await _client.from('booking').select('services_id')
    //   .eq('users_id', widget.booking!.usersId ?? '')
    //   // ... (sisa filter dari kode asli Anda)
    // Saya akan asumsikan Anda memiliki method di BookingService untuk ini
    // Jika tidak ada, Anda perlu menyesuaikan.
    if (_bookingService is BookingService && widget.booking?.id != null) { // Check if method exists (example)
      try {
        // Asumsi: Anda punya fungsi untuk mendapatkan services dari booking ID
        // atau Anda bisa menggunakan `_bookingService.getServicesByUserId` JIKA
        // services yang dipilih terikat pada user, bukan pada booking spesifik.
        // Logika asli Anda (_loadSelectedServices dari EditBookingFormPage) pakai getServicesByUserId
        // Saya akan gunakan itu untuk konsistensi, tapi ini mungkin perlu disesuaikan
        // tergantung bagaimana Anda menyimpan relasi booking-services.
        final servicesData = await _bookingService.getServicesByUserId(_selectedUserId ?? widget.booking!.usersId!);
        if (mounted) {
          setState(() {
            _selectedServices = servicesData ?? [];
            _calculateTotalPrice(); // Hitung ulang total jika service di-load
          });
        }
      } catch (e) {
        if (mounted) setState(() { _selectedServices = []; });
        print("Error loading selected services: $e");
      }
    } else {
      if (mounted) setState(() { _selectedServices = []; });
    }
  }


  Future<void> _loadServices() async {
    final servicesData = await _serviceService.getServices();
    if (!mounted) return;
    setState(() { _allServices = servicesData ?? []; });
  }

  void _onServiceSelected(bool selected, ServiceModel service) {
    if (!mounted) return;
    setState(() {
      if (selected) {
        if (!_selectedServices.any((s) => s.id == service.id)) { // Hindari duplikat
          _selectedServices.add(service);
        }
      } else {
        _selectedServices.removeWhere((s) => s.id == service.id);
      }
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    _totalPrice = 0.0;
    for (var service in _selectedServices) {
      num price = 0;
      if (service.price != null) {
        if (service.price is String) {
          price = double.tryParse(service.price as String) ?? 0.0;
        } else if (service.price is num) {
          price = service.price as num;
        }
      }
      _totalPrice += price;
    }
  }

  List<DateTime> _generateNext7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) => DateTime(now.year, now.month, now.day).add(Duration(days: index)));
  }

  List<TimeOfDay> _generateTimeSlots() {
    final List<TimeOfDay> slots = [];
    for (int hour = 9; hour <= 17; hour++) { // Jam 9 pagi sampai 5 sore
      slots.add(TimeOfDay(hour: hour, minute: 0));
      // slots.add(TimeOfDay(hour: hour, minute: 30)); // Jika ingin slot per 30 menit
    }
    return slots;
  }

  Future<void> _loadBookingsForSelectedDateAndMechanic() async {
    if (_selectedDate != null && _selectedMechanicId != null) {
      if (!mounted) return;
      // Ambil data booking yang sudah ada untuk tanggal & mekanik terpilih
      // untuk menandai slot waktu yang sudah terisi.
      final bookingsData = await _bookingService.getBookingsByDateAndMechanic(_selectedDate!, _selectedMechanicId!);
      if (mounted) {
        setState(() {
          _bookingsForSelectedDateAndMechanic = bookingsData ?? [];
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _bookingsForSelectedDateAndMechanic = [];
        });
      }
    }
  }

  bool _isTimeSlotBooked(TimeOfDay slot) { // Disederhanakan karena _bookingsForSelectedDateAndMechanic sudah ada
    for (var booking in _bookingsForSelectedDateAndMechanic) {
      if (booking.bookingsTime != null) {
        final parts = booking.bookingsTime!.split(':');
        if (parts.length >= 2) {
          final bookedHour = int.tryParse(parts[0]);
          // final bookedMinute = int.tryParse(parts[1]); // Jika slot per 30 menit, ini penting
          if (bookedHour == slot.hour /*&& bookedMinute == slot.minute*/) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _onDateSelected(DateTime date) {
    if (!mounted) return;
    setState(() {
      _selectedDate = date;
      _selectedTime = null; // Reset waktu saat tanggal berubah
    });
    _loadBookingsForSelectedDateAndMechanic(); // Load booking untuk tanggal & mekanik baru
  }

  void _onMechanicSelected(String? mechanicId) {
    if (!mounted) return;
    setState(() {
      _selectedMechanicId = mechanicId;
      _selectedTime = null; // Reset waktu saat mekanik berubah
    });
    // Jika tanggal sudah terpilih, load booking untuk tanggal & mekanik baru
    if (_selectedDate != null) {
      _loadBookingsForSelectedDateAndMechanic();
    }
  }

  Future<void> _saveBooking() async {
    // Logika _saveBooking dari kode asli Anda, dengan _isLoading diganti _isSaving
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null || _selectedMechanicId == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data customer, mekanik, tanggal, dan waktu!'), backgroundColor: Colors.orange));
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal satu jasa servis!'), backgroundColor: Colors.orange));
      return;
    }

    if (!mounted) return;
    setState(() { _isSaving = true; });

    final booking = BookingModel(
      id: widget.booking?.id, // null jika mode tambah
      usersId: _selectedUserId,
      mechanicsId: _selectedMechanicId,
      bookingsDate: _selectedDate,
      bookingsTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      status: _status, // _status diambil dari state, default 'Pending'
      notes: _notes,
      totalPrice: _totalPrice,
      createdAt: widget.booking?.createdAt ?? DateTime.now(), // createdAt jika tambah, atau yg lama jika edit
      updatedAt: DateTime.now(),
    );

    final bookingServices = _selectedServices.map((service) {
      num price = 0; // Konversi harga service ke num
      if (service.price != null) {
        if (service.price is String) {
          price = double.tryParse(service.price as String) ?? 0.0;
        } else if (service.price is num) {
          price = service.price as num;
        }
      }
      return BookingServiceModel(serviceId: service.id, price: price.toDouble()); // pastikan price adalah double
    }).toList();

    bool success;
    if (widget.booking == null) {
      success = await _bookingService.addBooking(booking, bookingServices);
    } else {
      success = await _bookingService.updateBooking(booking, bookingServices);
    }

    if (!mounted) return;
    setState(() { _isSaving = false; });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking berhasil ${widget.booking == null ? 'disimpan' : 'diperbarui'}!'), backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal ${widget.booking == null ? 'menyimpan' : 'memperbarui'} booking.'), backgroundColor: Colors.red));
    }
  }


  // Helper untuk membangun field input dengan style seragam
  Widget _buildStyledDropdown<T>({
    required String labelText,
    required IconData prefixIcon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    FormFieldValidator<T>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: 'Pilih $labelText',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(prefixIcon, color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
          filled: true,
          fillColor: Colors.white, // Atau Theme.of(context).colorScheme.surface.withOpacity(0.5)
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final Color disabledColor = Colors.grey[350]!;
    final Color disabledTextColor = Colors.grey[500]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'Formulir Booking Baru' : 'Edit Data Booking'),
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100], // Warna latar belakang utama
      body: _isLoadingPage
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Seksi 1: Customer & Mekanik ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Data Utama", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                    const Divider(height: 20),
                    _buildStyledDropdown<String>(
                      labelText: 'Customer',
                      prefixIcon: Icons.person_search_outlined,
                      value: _selectedUserId,
                      items: _profiles.map((profile) {
                        final userId = profile['users_id'] as String?;
                        return DropdownMenuItem<String>(
                          value: userId,
                          child: Text(profile['full_name'] ?? 'Nama Kosong'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedUserId = value),
                      validator: (value) => value == null || value.isEmpty ? 'Customer harus dipilih' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildStyledDropdown<String>(
                      labelText: 'Mekanik',
                      prefixIcon: Icons.handyman_outlined,
                      value: _selectedMechanicId,
                      items: _mechanics.map((mechanic) {
                        final mechanicId = mechanic['id'] as String?;
                        return DropdownMenuItem<String>(
                          value: mechanicId,
                          child: Text("${mechanic['full_name'] ?? 'Nama Kosong'} (${mechanic['spesialisasi'] ?? ' Umum'})"),
                        );
                      }).toList(),
                      onChanged: _onMechanicSelected, // Pakai _onMechanicSelected untuk trigger load booking
                      validator: (value) => value == null || value.isEmpty ? 'Mekanik harus dipilih' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Seksi 2: Pemilihan Tanggal ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pilih Tanggal Booking", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 75, // Tinggi container tanggal
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _generateNext7Days().length,
                        itemBuilder: (context, index) {
                          final date = _generateNext7Days()[index];
                          final isSelected = _selectedDate != null &&
                              date.year == _selectedDate!.year &&
                              date.month == _selectedDate!.month &&
                              date.day == _selectedDate!.day;
                          final dayName = DateFormat.E('id_ID').format(date); // Format hari (Sen, Sel)
                          final dayNumber = date.day.toString();
                          final isFriday = date.weekday == DateTime.friday; // Jumat libur

                          return GestureDetector(
                            onTap: isFriday ? null : () => _onDateSelected(date),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 65, // Lebar item tanggal
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                color: isFriday ? disabledColor.withOpacity(0.5) : (isSelected ? primaryColor : Colors.white),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!, width: 1.5),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 5, spreadRadius: 1)
                                ] : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dayName, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isFriday ? disabledTextColor : (isSelected ? onPrimaryColor : Colors.grey[700]))),
                                  const SizedBox(height: 4),
                                  Text(dayNumber, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isFriday ? disabledTextColor : (isSelected ? onPrimaryColor : primaryColor))),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedDate == null) Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text("Silakan pilih tanggal", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Seksi 3: Pemilihan Waktu ---
            if (_selectedDate != null) // Hanya tampilkan jika tanggal sudah dipilih
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pilih Waktu Booking", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(height: 12),
                      _mechanics == null && _selectedMechanicId == null // Tampilkan pesan jika mekanik belum dipilih
                          ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: Text("Pilih mekanik terlebih dahulu untuk melihat slot waktu.", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic))),
                      )
                          : Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: _generateTimeSlots().map((slot) {
                          final bool isBooked = _isTimeSlotBooked(slot);
                          final bool isSelected = _selectedTime == slot;
                          return ChoiceChip(
                            label: Text(
                              '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: isBooked ? disabledTextColor : (isSelected ? onPrimaryColor : Colors.black87),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            backgroundColor: Colors.grey[100],
                            selectedColor: primaryColor,
                            disabledColor: disabledColor.withOpacity(0.7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isBooked ? Colors.transparent : (isSelected ? primaryColor : Colors.grey[400]!))),
                            elevation: isSelected ? 2 : 0,
                            onSelected: isBooked ? null : (selected) {
                              if (selected && mounted) {
                                setState(() => _selectedTime = slot);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedDate != null && _mechanics != null && _selectedMechanicId != null && _selectedTime == null) Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: Text("Silakan pilih slot waktu", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // --- Seksi 4: Jasa Servis ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pilih Jasa Servis", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                    const Divider(height: 20),
                    if (_allServices.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Tidak ada jasa servis tersedia.", style: TextStyle(color: Colors.grey))))
                    else
                      ListView.builder( // Menggunakan ListView.builder agar tidak error jika terlalu banyak service
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allServices.length,
                        itemBuilder: (context, index) {
                          final service = _allServices[index];
                          final isSelected = _selectedServices.any((s) => s.id == service.id);
                          num priceValue = 0; // Konversi harga service
                          if (service.price != null) {
                            if (service.price is String) {
                              priceValue = double.tryParse(service.price as String) ?? 0;
                            } else if (service.price is num) {
                              priceValue = service.price as num;
                            }
                          }
                          return CheckboxListTile(
                            title: Text(service.serviceName ?? 'Nama Servis Error', style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(priceValue)),
                            value: isSelected,
                            onChanged: (bool? value) {
                              if (value != null) _onServiceSelected(value, service);
                            },
                            activeColor: primaryColor,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                    if (_selectedServices.isEmpty) Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text("Pilih minimal satu jasa servis.", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Harga:", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_totalPrice),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 17),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Seksi 5: Status & Catatan ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Status & Catatan Tambahan", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                    const Divider(height:20),
                    _buildStyledDropdown<String>(
                      labelText: 'Status Booking',
                      prefixIcon: Icons.flag_circle_outlined,
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                        DropdownMenuItem(value: 'On Progress', child: Text('On Progress')),
                        DropdownMenuItem(value: 'Done', child: Text('Done')),
                        DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        if (value != null && mounted) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        hintText: 'Masukkan catatan jika ada...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.note_alt_outlined, color: primaryColor.withOpacity(0.8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      initialValue: _notes,
                      maxLines: 3,
                      onChanged: (value) => _notes = value,
                      style: TextStyle(fontSize: 14.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Tombol Simpan/Update ---
            ElevatedButton.icon(
              icon: _isSaving ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: onPrimaryColor)) : Icon(widget.booking == null ? Icons.add_task_rounded : Icons.save_as_rounded, size: 20),
              label: Text(_isSaving ? 'Menyimpan...' : (widget.booking == null ? 'Simpan Booking' : 'Update Booking')),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: onPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSaving ? null : _saveBooking,
            ),
            const SizedBox(height: 20), // Spasi di akhir list
          ],
        ),
      ),
    );
  }
}