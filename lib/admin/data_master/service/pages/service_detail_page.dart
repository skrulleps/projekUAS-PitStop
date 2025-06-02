import 'package:flutter/material.dart';
import '../model/service_model.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailPage({Key? key, required this.service}) : super(key: key);

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailTile('Service Name', service.serviceName ?? '-'),
            _buildDetailTile('Description', service.description ?? '-'),
            _buildDetailTile('Price', service.price ?? '-'),
            _buildDetailTile('Created At',
                service.createdAt?.toLocal().toString() ?? '-'),
            _buildDetailTile('Updated At',
                service.updatedAt?.toLocal().toString() ?? '-'),
          ],
        ),
      ),
    );
  }
}
