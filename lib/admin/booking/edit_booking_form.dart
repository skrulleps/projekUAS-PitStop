import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model/booking_model.dart';
import 'model/booking_service_model.dart';
import 'booking_service/booking_service.dart';
import 'package:pitstop/admin/data_master/service/model/service_model.dart';
import 'package:pitstop/admin/booking/booking_service/booking_service_extension.dart';
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
    _loadServices();
    _loadBookingData();
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

  void _loadBookingData() async {
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
    await _loadSelectedServices();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSelectedServices() async {
    if (_selectedUserId == null) {
      setState(() {
        _selectedServices = [];
      });
      return;
    }
final services = await _bookingService.getServicesByUserId(_selectedUserId ?? '');
    setState(() {
      _selectedServices = services ?? [];
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
    if (_selectedUserId != null) {
      success = await _bookingService.updateStatusByUserId(_selectedUserId!, _status);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking berhasil diperbarui')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil memperbarui booking')));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : 'Pilih tanggal';
    final timeText = _selectedTime != null ? _selectedTime!.format(context) : 'Pilih waktu';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _profiles.firstWhere((p) => p['users_id'] == _selectedUserId, orElse: () => {})['full_name'] ?? '-',
                      decoration: const InputDecoration(labelText: 'User'),
                      readOnly: true,
                    ),
                    TextFormField(
                      initialValue: _mechanics.firstWhere((m) => m['id'] == _selectedMechanicId, orElse: () => {})['full_name'] ?? '-',
                      decoration: const InputDecoration(labelText: 'Mekanik'),
                      readOnly: true,
                    ),
                    TextFormField(
                      initialValue: dateText,
                      decoration: const InputDecoration(labelText: 'Tanggal Booking'),
                      readOnly: true,
                    ),
                    TextFormField(
                      initialValue: timeText,
                      decoration: const InputDecoration(labelText: 'Waktu Booking'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    const Text('Jasa Servis'),
                    ..._selectedServices.map((service) {
                      return ListTile(
                        title: Text(service.serviceName ?? '-'),
                        subtitle: Text('Harga: Rp ${service.price ?? '-'}'),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Text('Total Harga: Rp $_totalPrice'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: <String>['Pending', 'Confirmed', 'On Progress', 'Done', 'Cancelled']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _status = newValue ?? _status;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveBooking,
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
