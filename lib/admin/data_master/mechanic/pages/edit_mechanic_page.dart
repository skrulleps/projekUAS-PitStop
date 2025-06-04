import 'package:flutter/material.dart';
import '../model/mechanic_model.dart';
import 'package:pitstop/admin/data_master/mechanic/service/mechanic_service.dart';

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

<<<<<<< HEAD
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
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mekanik'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
>>>>>>> view2
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
<<<<<<< HEAD
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
=======
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Full Name wajib diisi'
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Phone wajib diisi' : null,
              ),
              TextFormField(
                controller: _spesialisasiController,
                decoration: const InputDecoration(labelText: 'Spesialisasi'),
              ),
>>>>>>> view2
              DropdownButtonFormField<String>(
                value: _statusController.text.isNotEmpty
                    ? _statusController.text
                    : null,
<<<<<<< HEAD
                decoration: _inputDecoration('Status'),
=======
                decoration: const InputDecoration(labelText: 'Status'),
>>>>>>> view2
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
<<<<<<< HEAD
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
=======
                validator: (value) => value == null || value.isEmpty
                    ? 'Status wajib dipilih'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan'),
              ),
>>>>>>> view2
            ],
          ),
        ),
      ),
    );
  }
}
