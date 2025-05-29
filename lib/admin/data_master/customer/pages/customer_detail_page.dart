import 'package:flutter/material.dart';
import '../model/customer_model.dart';

class CustomerDetailPage extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                backgroundImage: customer.photosBytes != null
                    ? MemoryImage(customer.photosBytes!)
                    : null,
                child: customer.photosBytes == null
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
