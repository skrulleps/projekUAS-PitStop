import 'package:flutter/material.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';

class MechanicFormPage extends StatefulWidget {
  const MechanicFormPage({Key? key}) : super(key: key);

  @override
  State<MechanicFormPage> createState() => _MechanicFormPageState();
}

class _MechanicFormPageState extends State<MechanicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  String? _selectedStatus;

  final List<String> _statusOptions = ['Active', 'Inactive', 'On Leave'];

  bool _isSaving = false;

  Future<void> _saveMechanic() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final mechanicData = {
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'spesialisasi': _specializationController.text.trim(),
      'status': _selectedStatus,
    };

    final success = await MechanicService().addMechanic(mechanicData);

    setState(() {
      _isSaving = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data mekanik berhasil disimpan')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data mekanik')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amber = Colors.amber.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.amber,
        backgroundColor: Colors.black,
        title: const Text(
          'Tambah Mekanik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: amber.withOpacity(0.7),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                validator: (value) => value == null || value.isEmpty ? 'Full Name wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Phone wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _specializationController,
                label: 'Spesialisasi',
                validator: (value) => value == null || value.isEmpty ? 'Spesialisasi wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(color: amber),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: amber, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: amber.withOpacity(0.6)),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: amber.withOpacity(0.1),
                ),
                dropdownColor: Colors.white,
                value: _selectedStatus,
                items: _statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Status wajib dipilih' : null,
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                    shadowColor: amber.withOpacity(0.6),
                  ),
                  onPressed: _isSaving ? null : _saveMechanic,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final amber = Colors.amber.shade700;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: amber),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: amber, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: amber.withOpacity(0.6)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: amber.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
