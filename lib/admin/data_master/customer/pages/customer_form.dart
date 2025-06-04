import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pitstop/admin/data_master/customer/service/customer_service.dart';

class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({Key? key}) : super(key: key);

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Uint8List? _photoBytes;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      setState(() {
        _photoBytes = bytes;
      });
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    String? avatarPath;
    if (_photoBytes != null) {
<<<<<<< HEAD
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/temp_avatar.jpg').writeAsBytes(_photoBytes!);
=======
      // Buat file sementara dari _photoBytes
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/temp_avatar.jpg').writeAsBytes(_photoBytes!);

      // Upload foto ke bucket avatar
>>>>>>> view2
      avatarPath = await CustomerService().uploadAvatar(file);
    }

    final customerData = {
      'full_name': _fullNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'photos': avatarPath,
    };

    final success = await CustomerService().addCustomer(customerData);

    setState(() {
      _isSaving = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data customer berhasil disimpan')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data customer')),
        );
      }
    }
  }

<<<<<<< HEAD
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Tambah Customer',
          style: TextStyle(color: Colors.amber),
        ),
        iconTheme: const IconThemeData(color: Colors.amber),
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Customer'),
>>>>>>> view2
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _photoBytes != null ? MemoryImage(_photoBytes!) : null,
<<<<<<< HEAD
                  backgroundColor: Colors.amber.shade100,
                  child: _photoBytes == null
                      ? const Icon(Icons.camera_alt, size: 50, color: Colors.black54)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration('Full Name'),
=======
                  child: _photoBytes == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
>>>>>>> view2
                validator: (value) =>
                    value == null || value.isEmpty ? 'Full Name wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
<<<<<<< HEAD
                decoration: _inputDecoration('Phone'),
=======
                decoration: const InputDecoration(labelText: 'Phone'),
>>>>>>> view2
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Phone wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
<<<<<<< HEAD
                decoration: _inputDecoration('Address'),
=======
                decoration: const InputDecoration(labelText: 'Address'),
>>>>>>> view2
                validator: (value) =>
                    value == null || value.isEmpty ? 'Address wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
<<<<<<< HEAD
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSaving ? null : _saveCustomer,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Simpan'),
=======
                onPressed: _isSaving ? null : _saveCustomer,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save'),
>>>>>>> view2
              ),
            ],
          ),
        ),
      ),
    );
  }
}
