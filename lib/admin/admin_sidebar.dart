// ignore_for_file: unused_field, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pitstop/auth/auth_repository.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';

class AdminSidebar extends StatefulWidget {
  const AdminSidebar({Key? key}) : super(key: key);

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  bool _isDataMasterExpanded = false;
  bool _isBookingExpanded = false;
  final bool _isLaporanExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
  child: SafeArea(
    child: Column(
      children: [
        // Header dengan bg hitam dan teks amber
        Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: const Text(
            'Admin Menu',
            style: TextStyle(color: Colors.amber, fontSize: 24),
          ),
        ),

        // Menu utama yang bisa discroll
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ExpansionTile(
                title: const Text(
                  'Data Master',
                  style: TextStyle(color: Colors.black87),
                ),
                leading: const Icon(Icons.folder, color: Colors.amber),
                initiallyExpanded: false,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isDataMasterExpanded = expanded;
                  });
                },
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle, color: Colors.amber),
                    title: const Text('Data Akun', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      context.go('/admin/data-master/data-akun');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.amber),
                    title: const Text('Data Customer', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      context.go('/admin/data-master/data-customer');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.build, color: Colors.amber),
                    title: const Text('Data Mekanik', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      context.go('/admin/data-master/data-mekanik');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.miscellaneous_services, color: Colors.amber),
                    title: const Text('Data Jenis Servis', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      context.go('/admin/data-master/data-jenis-servis');
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text(
                  'Booking',
                  style: TextStyle(color: Colors.black87),
                ),
                leading: const Icon(Icons.book_online, color: Colors.amber),
                initiallyExpanded: false,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isBookingExpanded = expanded;
                  });
                },
                children: [
                  ListTile(
                    leading: const Icon(Icons.list_alt, color: Colors.amber),
                    title: const Text('Data Booking', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      context.go('/admin/data-booking');
                    },
                  ),
                ],
              ),

              // Beri jarak ekstra sebelum Logout
              const SizedBox(height: 40),
            ],
          ),
        ),

        // Logout di footer, background hitam, teks amber
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: Colors.black,
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.amber),
            title: const Text('Logout', style: TextStyle(color: Colors.amber)),
            onTap: () async {
              final userBloc = BlocProvider.of<UserBloc>(context);
              final authRepository = AuthRepository();
              await authRepository.signOut(userBloc);
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop(); // close drawer
                // ignore: use_build_context_synchronously
                context.go('/login');
              }
            },
          ),
        ),
      ],
    ),
  ),
);

  }
}
