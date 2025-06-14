import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';

class EditCustomerPage extends StatefulWidget {
  final CustomerModel customer;

  const EditCustomerPage({Key? key, required this.customer}) : super(key: key);

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  Uint8List? _photoBytes;
  File? _photoFile;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.customer.fullName);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _addressController = TextEditingController(text: widget.customer.address);

    if (widget.customer.photos is String) {
      _photoBytes = null;
    } else {
      _photoBytes = widget.customer.photos as Uint8List?;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/temp_avatar.jpg').writeAsBytes(bytes);
      setState(() {
        _photoBytes = bytes;
        _photoFile = file;
      });
    }
  }

  bool _isSaving = false;

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      // ignore: unused_local_variable
      String? avatarPath;
      if (_photoFile != null) {
        avatarPath = await CustomerService().uploadAvatar(_photoFile!, userId: widget.customer.usersId);
      }

      final updateData = {
        'full_name': _fullNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final customerId = widget.customer.id;
      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID customer tidak valid')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      final success = await CustomerService().updateCustomer(customerId, updateData);

      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data customer berhasil diubah')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah data customer')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Customer', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber[700],
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.amber[100],
                    backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                    child: _photoBytes == null
                        ? const Icon(Icons.camera_alt, size: 50, color: Colors.black)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Full Name wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Phone wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Address wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.black,
                ),
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
