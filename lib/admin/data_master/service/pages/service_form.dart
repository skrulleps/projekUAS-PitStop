import 'package:flutter/material.dart';
import '../model/service_model.dart';
import 'package:pitstop/admin/data_master/service/service_service.dart';

class ServiceFormPage extends StatefulWidget {
  final ServiceModel? service;

  const ServiceFormPage({Key? key, this.service}) : super(key: key);

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _serviceNameController.text = widget.service!.serviceName ?? '';
      _descriptionController.text = widget.service!.description ?? '';
      _priceController.text = widget.service!.price ?? '';
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final serviceData = {
      'service_name': _serviceNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': _priceController.text.trim(),
    };

    bool success = false;
    if (widget.service == null) {
      success = await ServiceService().addService(serviceData);
    } else {
      success = await ServiceService().updateService(widget.service!.id!, serviceData);
    }

    setState(() {
      _isSaving = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.service == null ? 'Service berhasil ditambahkan' : 'Service berhasil diubah')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.service == null ? 'Gagal menambahkan service' : 'Gagal mengubah service')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Service' : 'Tambah Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) => value == null || value.isEmpty ? 'Service Name wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Description wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) => value == null || value.isEmpty ? 'Price wajib diisi' : null,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveService,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
