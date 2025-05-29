import 'package:flutter/material.dart';
import '../model/service_model.dart';
import 'package:pitstop/admin/data_master/service/service_service.dart';
import 'package:pitstop/admin/data_master/service/pages/service_detail_page.dart';
import 'package:pitstop/admin/data_master/service/pages/service_form.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final ServiceService _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
    });
    final services = await _serviceService.getServices();
    setState(() {
      _services = services ?? [];
      _isLoading = false;
    });
  }

  void _navigateToAdd() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ServiceFormPage()),
    );
    if (result == true) {
      _fetchServices();
    }
  }

  void _navigateToEdit(ServiceModel service) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ServiceFormPage(service: service)),
    );
    if (result == true) {
      _fetchServices();
    }
  }

  void _navigateToDetail(ServiceModel service) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ServiceDetailPage(service: service)),
    );
  }

  void _deleteService(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus service ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _serviceService.deleteService(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service berhasil dihapus')),
        );
        _fetchServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus service')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Service'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAdd,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('Belum ada data service'))
              : ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return ListTile(
                      title: Text(service.serviceName ?? '-'),
                      subtitle: Text(service.description ?? '-'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToEdit(service),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              if (service.id != null) {
                                _deleteService(service.id!);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () => _navigateToDetail(service),
                    );
                  },
                ),
    );
  }
}
