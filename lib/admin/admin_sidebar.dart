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
  bool _isLaporanExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber,
            ),
            child: Text('Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ExpansionTile(
            title: const Text('Data Master'),
            leading: const Icon(Icons.folder),
            initiallyExpanded: _isDataMasterExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isDataMasterExpanded = expanded;
              });
            },
            children: [
              ListTile(
                title: const Text('Data Akun'),
                onTap: () {
                  context.go('/admin/data-master/data-akun');
                },
              ),
              ListTile(
                title: const Text('Data Customer'),
                onTap: () {
                  context.go('/admin/data-master/data-customer');
                },
              ),
              ListTile(
                title: const Text('Data Mekanik'),
                onTap: () {
                  context.go('/admin/data-master/data-mekanik');
                },
              ),
              ListTile(
                title: const Text('Data Jenis Servis'),
                onTap: () {
                  context.go('/admin/data-master/data-jenis-servis');
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Booking'),
            leading: const Icon(Icons.book_online),
            initiallyExpanded: _isBookingExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isBookingExpanded = expanded;
              });
            },
            children: [
              ListTile(
                title: const Text('Data Booking'),
                onTap: () {
                  context.go('/admin/data-booking');
                },
              ),
            ],
          ),
          // ExpansionTile(
          //   title: const Text('Laporan'),
          //   leading: const Icon(Icons.insert_chart),
          //   initiallyExpanded: _isLaporanExpanded,
          //   onExpansionChanged: (expanded) {
          //     setState(() {
          //       _isLaporanExpanded = expanded;
          //     });
          //   },
          //   children: [
          //     ListTile(
          //       title: const Text('Laporan Pendapatan'),
          //       onTap: () {
          //         context.go('/admin/laporan/laporan-pendapatan');
          //       },
          //     ),
          //     ListTile(
          //       title: const Text('Laporan Booking'),
          //       onTap: () {
          //         context.go('/admin/laporan/laporan-booking');
          //       },
          //     ),
          //   ],
          // ), 
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final userBloc = BlocProvider.of<UserBloc>(context);
              final authRepository = AuthRepository();
              await authRepository.signOut(userBloc);
              if (mounted) {
                Navigator.of(context).pop(); // close drawer
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
