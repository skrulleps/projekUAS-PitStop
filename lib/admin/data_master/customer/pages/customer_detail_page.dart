import 'package:flutter/material.dart';
import '../model/customer_model.dart';
import '../service/customer_service.dart';

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
<<<<<<< HEAD
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          customer.fullName ?? 'Detail Customer',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber[700],
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
=======
      appBar: AppBar(
        title: Text(customer.fullName ?? 'Detail Customer'),
>>>>>>> view2
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
<<<<<<< HEAD
                backgroundColor: Colors.amber[100],
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.black)
=======
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 60)
>>>>>>> view2
                    : null,
              ),
            ),
            const SizedBox(height: 20),
<<<<<<< HEAD

            _buildInfoTile('Full Name', customer.fullName),
            _buildInfoTile('Phone', customer.phone),
            _buildInfoTile('Address', customer.address),
            _buildInfoTile('Created At', customer.createdAt?.toLocal().toString()),
            _buildInfoTile('Updated At', customer.updatedAt?.toLocal().toString()),
=======
            ListTile(
              title: const Text('Full Name'),
              subtitle: Text(customer.fullName ?? '-'),
            ),
            ListTile(
              title: const Text('Phone'),
              subtitle: Text(customer.phone ?? '-'),
            ),
            ListTile(
              title: const Text('Address'),
              subtitle: Text(customer.address ?? '-'),
            ),
            ListTile(
              title: const Text('Created At'),
              subtitle: Text(customer.createdAt?.toLocal().toString() ?? '-'),
            ),
            ListTile(
              title: const Text('Updated At'),
              subtitle: Text(customer.updatedAt?.toLocal().toString() ?? '-'),
            ),
>>>>>>> view2
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD

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
=======
>>>>>>> view2
}
