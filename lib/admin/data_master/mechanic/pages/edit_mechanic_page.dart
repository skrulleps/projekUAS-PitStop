import 'package:flutter/material.dart';
import '../../../../data/model/mechanic/mechanic_model.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';

class EditMechanicPage extends StatefulWidget {
  final MechanicModel mechanic;

  const EditMechanicPage({Key? key, required this.mechanic}) : super(key: key);

  @override
  State<EditMechanicPage> createState() => _EditMechanicPageState();
}

class _EditMechanicPageState extends State<EditMechanicPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _spesialisasiController;
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.mechanic.fullName);
    _phoneController = TextEditingController(text: widget.mechanic.phone);
    _spesialisasiController =
        TextEditingController(text: widget.mechanic.spesialisasi);
    _statusController = TextEditingController(text: widget.mechanic.status);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _spesialisasiController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'full_name': _fullNameController.text,
        'phone': _phoneController.text,
        'spesialisasi': _spesialisasiController.text,
        'status': _statusController.text,
      };

      final mechanicId = widget.mechanic.id;
      if (mechanicId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID mekanik tidak valid')),
        );
        return;
      }
      final success = await MechanicService().updateMechanic(
        mechanicId.toString(),
        updateData,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data mekanik berhasil diubah')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah data mekanik')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber.shade700, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar hitam
        iconTheme: const IconThemeData(color: Colors.amber), // Icon amber
        title: const Text(
          'Edit Mekanik',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration('Full Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Full Name wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Phone'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Phone wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _spesialisasiController,
                decoration: _inputDecoration('Spesialisasi'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _statusController.text.isNotEmpty
                    ? _statusController.text
                    : null,
                decoration: _inputDecoration('Status'),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'On Leave', child: Text('On Leave')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _statusController.text = value;
                    });
                  }
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Status wajib dipilih' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _save,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
