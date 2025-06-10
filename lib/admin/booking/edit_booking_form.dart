import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/booking/booking_model.dart';
import '../../data/model/booking/booking_service_model.dart';
import '../../data/api/booking/booking_service.dart';
import 'package:pitstop/data/model/service/service_model.dart';
import 'package:pitstop/data/api/booking/booking_service_extension.dart';
import 'package:pitstop/admin/data_master/service/service_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    _isLoading = true;
    _loadProfiles();
    _loadMechanics();
    _loadServices().then((_) async {
      _loadBookingData();
      await _loadSelectedServices();
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _loadProfiles() async {
    final response = await _client.from('profiles').select('id, full_name, users_id');
    if (response == null) {
      setState(() {
        _profiles = [];
      });
      return;
    }
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
    setState(() {
      _mechanics = List<Map<String, dynamic>>.from(response ?? []);
    });
  }

  void _loadBookingData() {
    final booking = widget.booking;
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
  }

  Future<void> _loadSelectedServices() async {
    if (widget.booking == null) {
      _selectedServices = [];
      return;
    }
    final booking = widget.booking;
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

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    bool success = false;
    if (_selectedUserId != null && _selectedDate != null && _selectedTime != null) {
      final timeStr = _selectedTime!.format(context);
      success = await _bookingService.updateStatusByUserIdDateTime(_selectedUserId!, _selectedDate!, timeStr, _status);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking berhasil diperbarui')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui booking')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'Pilih tanggal';
    final timeText = _selectedTime != null ? _selectedTime!.format(context) : 'Pilih waktu';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Booking', style: TextStyle(color: Colors.amber)),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              color: Colors.amber,
              onRefresh: () async {
                setState(() {
                  _isLoading = true;
                });
                await _loadProfiles();
                await _loadMechanics();
                await _loadServices();
                _loadBookingData();
                await _loadSelectedServices();
                setState(() {
                  _isLoading = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _profiles.firstWhere((p) => p['users_id'] == _selectedUserId, orElse: () => {})['full_name'] ?? '-',
                        decoration: const InputDecoration(
                          labelText: 'User',
                          labelStyle: TextStyle(color: Colors.black87),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _mechanics.firstWhere((m) => m['id'] == _selectedMechanicId, orElse: () => {})['full_name'] ?? '-',
                        decoration: const InputDecoration(
                          labelText: 'Mekanik',
                          labelStyle: TextStyle(color: Colors.black87),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: dateText,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Booking',
                          labelStyle: TextStyle(color: Colors.black87),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: timeText,
                        decoration: const InputDecoration(
                          labelText: 'Waktu Booking',
                          labelStyle: TextStyle(color: Colors.black87),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        readOnly: true,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Jasa Servis',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      ..._selectedServices.map((service) {
                        return ListTile(
                          tileColor: Colors.amber.shade50,
                          title: Text(service.serviceName ?? '-', style: const TextStyle(color: Colors.black87)),
                          subtitle: Text('Harga: Rp ${service.price ?? '-'}', style: const TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      Text(
                        'Total Harga: Rp $_totalPrice',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          labelStyle: TextStyle(color: Colors.black87),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        items: <String>['Pending', 'Confirmed', 'On Progress', 'Done', 'Cancelled']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: Colors.black87)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _status = value ?? _status;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        initialValue: _notes,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Catatan',
                          labelStyle: const TextStyle(color: Colors.black87),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        onChanged: (value) {
                          _notes = value;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _saveBooking,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.amber)
                            : const Text('Simpan Perubahan'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
