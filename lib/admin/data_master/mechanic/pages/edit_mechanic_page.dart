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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mekanik'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
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
              DropdownButtonFormField<String>(
                value: _statusController.text.isNotEmpty
                    ? _statusController.text
                    : null,
                decoration: const InputDecoration(labelText: 'Status'),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Status wajib dipilih'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
