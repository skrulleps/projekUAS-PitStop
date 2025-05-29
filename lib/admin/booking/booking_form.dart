import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/booking_model.dart';
import 'model/booking_service_model.dart';
import 'booking_service/booking_service.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
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
    final response = await _client.from('profiles').select('id, full_name, users_id');
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
    final response = await _client.from('mechanics').select('id, full_name, spesialisasi, status').eq('status', 'Active');
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
        _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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
    final response = await _client.from('booking').select('services_id')
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
    final selected = _allServices.where((service) => serviceIds.contains(service.id)).toList();
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

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null || _selectedMechanicId == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data')));
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal satu jasa servis')));
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
      bookingsTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
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
      print('DEBUG: Adding booking with data: $booking and services: $bookingServices');
      success = await _bookingService.addBooking(booking, bookingServices);
    } else {
      print('DEBUG: Updating booking with data: $booking and services: $bookingServices');
      success = await _bookingService.updateBooking(booking, bookingServices);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking berhasil disimpan')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan booking')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'Pilih tanggal';
    final timeText = _selectedTime != null ? _selectedTime!.format(context) : 'Pilih waktu';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.booking == null ? 'Tambah Booking' : 'Edit Booking'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      decoration: const InputDecoration(labelText: 'User'),
                      items: _profiles.map((profile) {
                        final userId = profile['users_id'];
                        return DropdownMenuItem<String>(
                          value: userId != null ? userId as String : null,
                          child: Text(profile['full_name'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUserId = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'User harus dipilih' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedMechanicId,
                      decoration: const InputDecoration(labelText: 'Mekanik'),
                      isExpanded: true,
                      items: _mechanics.map((mechanic) {
                        final mechanicId = mechanic['id'];
                        return DropdownMenuItem<String>(
                          value: mechanicId != null ? mechanicId as String : null,
                          child: Text('${mechanic['full_name'] ?? '-'} - ${mechanic['spesialisasi'] ?? '-'}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMechanicId = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Mekanik harus dipilih' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Tanggal Booking'),
                      subtitle: Text(dateText),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    ListTile(
                      title: const Text('Waktu Booking'),
                      subtitle: Text(timeText),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'Confirmed', child: Text('Confirmed')),
                        DropdownMenuItem(value: 'On Progress', child: Text('On Progress')),
                        DropdownMenuItem(value: 'Done', child: Text('Done')),
                        DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Jasa Servis'),
                    ..._allServices.map((service) {
                      final selected = _selectedServices.any((s) => s.id == service.id);
                      return CheckboxListTile(
                        title: Text(service.serviceName ?? '-'),
                        subtitle: Text('Harga: Rp ${service.price ?? '-'}'),
                        value: selected,
                        onChanged: (bool? value) {
                          if (value != null) {
                            _onServiceSelected(value, service);
                          }
                        },
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Text('Total Harga: Rp $_totalPrice'),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Catatan'),
                      initialValue: _notes,
                      maxLines: 3,
                      onChanged: (value) => _notes = value,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveBooking,
                      child: Text(widget.booking == null ? 'Simpan' : 'Update'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
