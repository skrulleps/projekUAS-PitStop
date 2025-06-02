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
            child: const Text('Hapus', style: TextStyle(color: Colors.amber)),
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
      backgroundColor: Colors.white,  // Background putih
      appBar: AppBar(
        foregroundColor: Colors.amber,
        backgroundColor: Colors.black,  // AppBar hitam
        title: const Text('Daftar Service'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.amber),  // Icon amber
            onPressed: _navigateToAdd,
            tooltip: 'Tambah Service',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _services.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data service',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          service.serviceName ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.description ?? '-',
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Harga: Rp ${service.price ?? '-'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.amber),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _navigateToEdit(service),
                              tooltip: 'Edit Service',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                if (service.id != null) {
                                  _deleteService(service.id!);
                                }
                              },
                              tooltip: 'Hapus Service',
                            ),
                          ],
                        ),
                        onTap: () => _navigateToDetail(service),
                      ),
                    );
                  },
                ),
    );
  }
}
