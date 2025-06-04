import 'package:flutter/material.dart';
import '../model/service_model.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailPage({Key? key, required this.service}) : super(key: key);

<<<<<<< HEAD
  Widget _buildDetailTile(String title, String value) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.amber, width: 0.8),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar hitam
        iconTheme: const IconThemeData(color: Colors.amber), // Icon amber
        title: Text(
          service.serviceName ?? 'Detail Service',
          style: const TextStyle(color: Colors.amber),
        ),
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.serviceName ?? 'Detail Service'),
>>>>>>> view2
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
<<<<<<< HEAD
            _buildDetailTile('Service Name', service.serviceName ?? '-'),
            _buildDetailTile('Description', service.description ?? '-'),
            _buildDetailTile('Price', service.price ?? '-'),
            _buildDetailTile('Created At',
                service.createdAt?.toLocal().toString() ?? '-'),
            _buildDetailTile('Updated At',
                service.updatedAt?.toLocal().toString() ?? '-'),
=======
            ListTile(
              title: const Text('Service Name'),
              subtitle: Text(service.serviceName ?? '-'),
            ),
            ListTile(
              title: const Text('Description'),
              subtitle: Text(service.description ?? '-'),
            ),
            ListTile(
              title: const Text('Price'),
              subtitle: Text(service.price ?? '-'),
            ),
            ListTile(
              title: const Text('Created At'),
              subtitle: Text(service.createdAt?.toLocal().toString() ?? '-'),
            ),
            ListTile(
              title: const Text('Updated At'),
              subtitle: Text(service.updatedAt?.toLocal().toString() ?? '-'),
            ),
>>>>>>> view2
          ],
        ),
      ),
    );
  }
}
