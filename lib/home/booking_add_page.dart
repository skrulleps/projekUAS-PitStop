import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/booking/booking_model.dart';
import '../../data/model/booking/booking_service_model.dart';
import '../../data/api/booking/booking_service.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/admin/data_master/service/service_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingAddPage extends StatefulWidget {
  final String userId;
  final String userFullName;

  const BookingAddPage({Key? key, required this.userId, required this.userFullName}) : super(key: key);

  @override
  State<BookingAddPage> createState() => _BookingAddPageState();
}

class _BookingAddPageState extends State<BookingAddPage> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService();
  final ServiceService _serviceService = ServiceService();
  final SupabaseClient _client = Supabase.instance.client;

  late String _selectedUserId;
  String? _selectedMechanicId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _status = 'Pending';
  String? _notes;
  List<ServiceModel> _allServices = [];
  List<ServiceModel> _selectedServices = [];
  double _totalPrice = 0.0;

  List<Map<String, dynamic>> _mechanics = [];

  bool _isLoading = false;

  List<BookingModel> _bookingsForSelectedDateAndMechanic = [];
  List<BookingModel> _bookingsForNext7DaysAndMechanic = [];

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.userId;
    _loadMechanics();
    _loadServices();
  }

  Future<void> _loadMechanics() async {
    final response = await _client
        .from('mechanics')
        .select('id, full_name, spesialisasi, status')
        .eq('status', 'Active');
    setState(() {
      _mechanics = List<Map<String, dynamic>>.from(response ?? []);
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

  List<DateTime> _generateNext7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) => now.add(Duration(days: index)));
  }

  List<TimeOfDay> _generateTimeSlots() {
    final List<TimeOfDay> slots = [];
    for (int hour = 9; hour <= 17; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

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

  Future<void> _loadBookingsForSelectedDateAndMechanic() async {
    if (_selectedDate != null && _selectedMechanicId != null) {
      final bookings = await _bookingService.getBookingsByDateAndMechanic(
          _selectedDate!, _selectedMechanicId!);
      setState(() {
        _bookingsForSelectedDateAndMechanic = bookings ?? [];
      });
    } else {
      setState(() {
        _bookingsForSelectedDateAndMechanic = [];
      });
    }
  }

  Future<void> _loadBookingsForNext7DaysAndMechanic() async {
    if (_selectedMechanicId != null) {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 7));
      final bookings = await _bookingService.getBookingsByMechanicAndDateRange(
          _selectedMechanicId!, now, endDate);
      setState(() {
        _bookingsForNext7DaysAndMechanic = bookings ?? [];
      });
    } else {
      setState(() {
        _bookingsForNext7DaysAndMechanic = [];
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });
    _loadBookingsForSelectedDateAndMechanic();
  }

  void _onMechanicSelected(String? mechanicId) {
    setState(() {
      _selectedMechanicId = mechanicId;
      _selectedTime = null;
    });
    if (_selectedDate != null) {
      _loadBookingsForSelectedDateAndMechanic();
    }
    _loadBookingsForNext7DaysAndMechanic();
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId.isEmpty ||
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
      usersId: _selectedUserId,
      mechanicsId: _selectedMechanicId,
      bookingsDate: _selectedDate,
      bookingsTime:
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
      status: _status,
      notes: _notes,
      totalPrice: _totalPrice,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final bookingServices = _selectedServices.map((service) {
      final price = double.tryParse(service.price ?? '0') ?? 0.0;
      return BookingServiceModel(
        serviceId: service.id,
        price: price,
      );
    }).toList();

    bool success = await _bookingService.addBooking(booking, bookingServices);

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
        title: const Text('Tambah Booking'),
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
                    // Display user full name as non-editable
                    TextFormField(
                      initialValue: widget.userFullName,
                      decoration: const InputDecoration(labelText: 'User'),
                      enabled: false,
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

                      // Disable date if any booking exists on that date for selected mechanic
                      final isBookedDate = _bookingsForNext7DaysAndMechanic.any((booking) {
                        final bookingDate = booking.bookingsDate;
                        if (bookingDate == null) return false;
                        return bookingDate.year == date.year &&
                            bookingDate.month == date.month &&
                            bookingDate.day == date.day;
                      });

                      return GestureDetector(
                        onTap: (isFriday || isBookedDate)
                            ? null
                            : () async {
                                _onDateSelected(date);
                                await _loadBookingsForSelectedDateAndMechanic();
                              },
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: (isFriday || isBookedDate)
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
                                  color: (isFriday || isBookedDate)
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
                                  color: (isFriday || isBookedDate)
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

                        // Disable time slot if it is before current time on the selected date (if today)
                        bool isPastTime = false;
                        if (_selectedDate != null) {
                          final now = TimeOfDay.now();
                          final today = DateTime.now();
                          if (_selectedDate!.year == today.year &&
                              _selectedDate!.month == today.month &&
                              _selectedDate!.day == today.day) {
                            if (slot.hour < now.hour ||
                                (slot.hour == now.hour && slot.minute <= now.minute)) {
                              isPastTime = true;
                            }
                          }
                        }

                        return ChoiceChip(
                          label: Text(
                              '${slot.hour.toString().padLeft(2, '0')}:00'),
                          selected: isSelected,
                          onSelected: (isBooked || isPastTime)
                              ? null
                              : (selected) {
                                  if (selected)
                                    setState(() => _selectedTime = slot);
                                },
                          selectedColor: Colors.amber[700],
                          disabledColor: Colors.grey[300],
                          backgroundColor: Colors.grey[100],
                          labelStyle: TextStyle(
                            color: (isBooked || isPastTime)
                                ? Colors.grey
                                : isSelected
                                    ? Colors.black
                                    : Colors.black87,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    DropdownButtonFormField<String>(
                      value: 'Pending',
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Pending', child: Text('Pending')),
                      ],
                      onChanged: null,
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
                        child: const Text('Simpan Booking'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
