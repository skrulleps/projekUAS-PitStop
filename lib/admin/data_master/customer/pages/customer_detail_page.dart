import 'package:flutter/material.dart';
import '../../../../data/model/customer/customer_model.dart';
import '../../../../data/api/customer/customer_service.dart';

class CustomerDetailPage extends StatelessWidget {
  final CustomerModel customer;
  final CustomerService _customerService = CustomerService();

  CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? photoPath = customer.photos;
    String? photoUrl = photoPath != null && photoPath.isNotEmpty
        ? _customerService.getAvatarUrl(photoPath)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          customer.fullName ?? 'Detail Customer',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber[700],
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.amber[100],
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            _buildInfoTile('Full Name', customer.fullName),
            _buildInfoTile('Phone', customer.phone),
            _buildInfoTile('Address', customer.address),
            _buildInfoTile('Created At', customer.createdAt?.toLocal().toString()),
            _buildInfoTile('Updated At', customer.updatedAt?.toLocal().toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      subtitle: Text(
        value ?? '-',
        style: const TextStyle(color: Colors.black54),
      ),
      leading: const Icon(Icons.label, color: Colors.amber),
    );
  }
}
