import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/booking/booking_model.dart';
import '../../data/model/booking/booking_service_model.dart';
import '../../data/api/booking/booking_service.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/admin/data_master/service/service_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingFormPage extends StatefulWidget {
  final BookingModel? booking;

  const BookingFormPage({Key? key, this.booking}) : super(key: key);

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final ServiceService _serviceService = ServiceService();
  final SupabaseClient _client = Supabase.instance.client;

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

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _loadMechanics();
    _loadServices();
    if (widget.booking != null) {
      _loadBookingData();
    }
  }

  Future<void> _loadProfiles() async {
    final response =
        await _client.from('profiles').select('id, full_name, users_id');
    if (response == null) {
      setState(() {
        _profiles = [];
      });
      return;
    }
    // Filter duplicate users_id
    final uniqueProfilesMap = <String, Map<String, dynamic>>{};
    for (var profile in response) {
      final userId = profile['users_id'];
      if (userId != null && !uniqueProfilesMap.containsKey(userId)) {
        uniqueProfilesMap[userId] = profile;
      }
    }
    setState(() {
      _profiles = uniqueProfilesMap.values.toList();
    });
  }

  Future<void> _loadMechanics() async {
    final response = await _client
        .from('mechanics')
        .select('id, full_name, spesialisasi, status')
        .eq('status', 'Active');
    print('DEBUG: mechanics response: $response');
    setState(() {
      _mechanics = List<Map<String, dynamic>>.from(response ?? []);
    });
  }

  void _loadBookingData() async {
    final booking = widget.booking!;
    _selectedUserId = booking.usersId;
    _selectedMechanicId = booking.mechanicsId;
    _selectedDate = booking.bookingsDate;
    if (booking.bookingsTime != null) {
      final parts = booking.bookingsTime!.split(':');
      if (parts.length >= 2) {
        _selectedTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }
    _status = booking.status ?? 'Pending';
    _notes = booking.notes;
    _totalPrice = booking.totalPrice ?? 0.0;
    await _loadSelectedServices();
  }

  Future<void> _loadSelectedServices() async {
    if (widget.booking == null) {
      _selectedServices = [];
      return;
    }
    final booking = widget.booking!;
    final response = await _client
        .from('booking')
        .select('services_id')
        .eq('users_id', booking.usersId ?? '')
        .eq('bookings_date', booking.bookingsDate?.toIso8601String() ?? '')
        .eq('bookings_time', booking.bookingsTime ?? '')
        .eq('mechanics_id', booking.mechanicsId ?? '')
        .eq('status', booking.status ?? '');
    if (response == null) {
      _selectedServices = [];
      return;
    }
    final serviceIds = <String>[];
    for (var item in response) {
      final serviceId = item['services_id'];
      if (serviceId != null) {
        serviceIds.add(serviceId as String);
      }
    }
    final selected = _allServices
        .where((service) => serviceIds.contains(service.id))
        .toList();
    setState(() {
      _selectedServices = selected;
    });
  }

  Future<void> _loadServices() async {
    final services = await _serviceService.getServices();
    setState(() {
      _allServices = services ?? [];
    });
  }

  void _onServiceSelected(bool selected, ServiceModel service) {
    setState(() {
      if (selected) {
        _selectedServices.add(service);
      } else {
        _selectedServices.removeWhere((s) => s.id == service.id);
      }
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    _totalPrice = 0.0;
    for (var service in _selectedServices) {
      final price = double.tryParse(service.price ?? '0') ?? 0.0;
      _totalPrice += price;
    }
  }

  // Remove _selectDate and _selectTime methods

  // New method to generate list of next 7 days starting from today
  List<DateTime> _generateNext7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  // New method to generate time slots from 09:00 to 17:00
  List<TimeOfDay> _generateTimeSlots() {
    final List<TimeOfDay> slots = [];
    for (int hour = 9; hour <= 17; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

  // New method to check if a time slot is booked
  bool _isTimeSlotBooked(TimeOfDay slot, List<BookingModel> bookings) {
    for (var booking in bookings) {
      if (booking.bookingsTime != null) {
        final parts = booking.bookingsTime!.split(':');
        if (parts.length >= 2) {
          final bookedHour = int.tryParse(parts[0]);
          final bookedMinute = int.tryParse(parts[1]);
          if (bookedHour == slot.hour && bookedMinute == slot.minute) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // New state to hold bookings for selected date and mechanic
  List<BookingModel> _bookingsForSelectedDateAndMechanic = [];

  // New method to load bookings for selected date and mechanic
  Future<void> _loadBookingsForSelectedDateAndMechanic() async {
    if (_selectedDate != null && _selectedMechanicId != null) {
      setState(() async {
        final bookings = await _bookingService.getBookingsByDateAndMechanic(
            _selectedDate!, _selectedMechanicId!);
        _bookingsForSelectedDateAndMechanic = bookings ?? [];
      });
    } else {
      setState(() {
        _bookingsForSelectedDateAndMechanic = [];
      });
    }
  }

  // Update _selectedDate setter to load bookings
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null; // reset selected time when date changes
    });
    _loadBookingsForSelectedDateAndMechanic();
  }

  // Update _selectedMechanicId setter to reload bookings if date is selected
  void _onMechanicSelected(String? mechanicId) {
    setState(() {
      _selectedMechanicId = mechanicId;
      _selectedTime = null; // reset selected time when mechanic changes
    });
    if (_selectedDate != null) {
      _loadBookingsForSelectedDateAndMechanic();
    }
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null ||
        _selectedMechanicId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lengkapi semua data')));
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih minimal satu jasa servis')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final booking = BookingModel(
      id: widget.booking?.id,
      usersId: _selectedUserId,
      mechanicsId: _selectedMechanicId,
      bookingsDate: _selectedDate,
      bookingsTime:
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      status: _status,
      notes: _notes,
      totalPrice: _totalPrice,
      createdAt: widget.booking?.createdAt,
      updatedAt: DateTime.now(),
    );

    final bookingServices = _selectedServices.map((service) {
      final price = double.tryParse(service.price ?? '0') ?? 0.0;
      return BookingServiceModel(
        serviceId: service.id,
        price: price,
      );
    }).toList();

    bool success;
    if (widget.booking == null) {
      print(
          'DEBUG: Adding booking with data: $booking and services: $bookingServices');
      success = await _bookingService.addBooking(booking, bookingServices);
    } else {
      print(
          'DEBUG: Updating booking with data: $booking and services: $bookingServices');
      success = await _bookingService.updateBooking(booking, bookingServices);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking berhasil disimpan')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan booking')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : 'Pilih tanggal';
    final timeText =
        _selectedTime != null ? _selectedTime!.format(context) : 'Pilih waktu';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.booking == null ? 'Tambah Booking' : 'Edit Booking'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // User Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      decoration: const InputDecoration(labelText: 'User'),
                      items: _profiles.map((profile) {
                        return DropdownMenuItem<String>(
                          value: profile['users_id'] as String?,
                          child: Text(profile['full_name'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedUserId = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'User harus dipilih'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Mechanic Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedMechanicId,
                      decoration: const InputDecoration(labelText: 'Mekanik'),
                      isExpanded: true,
                      items: _mechanics.map((mechanic) {
                        return DropdownMenuItem<String>(
                          value: mechanic['id'] as String?,
                          child: Text(
                              '${mechanic['full_name']} - ${mechanic['spesialisasi']}'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedMechanicId = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Mekanik harus dipilih'
                          : null,
                    ),

                    const SizedBox(height: 24),

                    const Text('Tanggal Booking',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _generateNext7Days().length,
                        itemBuilder: (context, index) {
                          final date = _generateNext7Days()[index];
                          final isSelected = _selectedDate != null &&
                              date.year == _selectedDate!.year &&
                              date.month == _selectedDate!.month &&
                              date.day == _selectedDate!.day;
                          final isFriday = date.weekday == DateTime.friday;
                          return GestureDetector(
                            onTap: isFriday
                                ? null
                                : () async {
                                    _onDateSelected(date);
                                    await _loadBookingsForSelectedDateAndMechanic();
                                  },
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isFriday
                                    ? Colors.grey[300]
                                    : isSelected
                                        ? Colors.amber[700]
                                        : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[400]!,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat.E().format(date),
                                    style: TextStyle(
                                      color: isFriday
                                          ? Colors.grey
                                          : isSelected
                                              ? Colors.black
                                              : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isFriday
                                          ? Colors.grey
                                          : isSelected
                                              ? Colors.black
                                              : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text('Waktu Booking',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _generateTimeSlots().map((slot) {
                        final isBooked = _isTimeSlotBooked(
                            slot, _bookingsForSelectedDateAndMechanic);
                        final isSelected = _selectedTime != null &&
                            _selectedTime!.hour == slot.hour &&
                            _selectedTime!.minute == slot.minute;
                        return ChoiceChip(
                          label: Text(
                              '${slot.hour.toString().padLeft(2, '0')}:00'),
                          selected: isSelected,
                          onSelected: isBooked
                              ? null
                              : (selected) {
                                  if (selected)
                                    setState(() => _selectedTime = slot);
                                },
                          selectedColor: Colors.amber[700],
                          disabledColor: Colors.grey[300],
                          backgroundColor: Colors.grey[100],
                          labelStyle: TextStyle(
                            color: isBooked
                                ? Colors.grey
                                : isSelected
                                    ? Colors.black
                                    : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'Confirmed', child: Text('Confirmed')),
                        DropdownMenuItem(
                            value: 'On Progress', child: Text('On Progress')),
                        DropdownMenuItem(value: 'Done', child: Text('Done')),
                        DropdownMenuItem(
                            value: 'Cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) =>
                          setState(() => _status = value ?? _status),
                    ),

                    const SizedBox(height: 24),

                    const Text('Pilih Jasa Servis',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    ..._allServices.map((service) {
                      final selected =
                          _selectedServices.any((s) => s.id == service.id);
                      return CheckboxListTile(
                        title: Text(service.serviceName ?? '-'),
                        subtitle: Text('Harga: Rp ${service.price ?? '-'}'),
                        value: selected,
                        onChanged: (value) =>
                            _onServiceSelected(value ?? false, service),
                        activeColor: Colors.amber[700],
                        checkColor: Colors.black,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    Text('Total Harga: Rp $_totalPrice',
                        style: const TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Catatan'),
                      initialValue: _notes,
                      maxLines: 3,
                      onChanged: (value) => _notes = value,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.booking == null
                            ? 'Simpan Booking'
                            : 'Update Booking'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
