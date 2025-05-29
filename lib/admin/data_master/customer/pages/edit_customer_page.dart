import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../model/customer_model.dart';
import '../service/customer_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.customer.fullName);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _addressController = TextEditingController(text: widget.customer.address);
    // Convert photos from String? to Uint8List? if needed
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

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final updateData = {
        'full_name': _fullNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'photos': _photoBytes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final customerId = widget.customer.id;
      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID customer tidak valid')),
        );
        return;
      }
      final success = await CustomerService().updateCustomer(
        customerId,
        updateData,
      );

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
      appBar: AppBar(
        title: const Text('Edit Customer'),
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
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Address wajib diisi'
                    : null,
              ),
              if (_photoBytes != null)
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(_photoBytes!),
                  ),
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
