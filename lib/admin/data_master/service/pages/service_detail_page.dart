import 'package:flutter/material.dart';
import '../model/service_model.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailPage({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service.serviceName ?? 'Detail Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
          ],
        ),
      ),
    );
  }
}
