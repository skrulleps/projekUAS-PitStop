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
      appBar: AppBar(
        title: Text(customer.fullName ?? 'Detail Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}
