import 'package:flutter/material.dart';
import 'package:pitstop/home/profile_page.dart';
import 'package:pitstop/home/booking_page.dart';
import 'package:pitstop/home/history_page.dart';
import 'homepage_content.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
        HomepageContent(onSearchSubmitted: _handleSearch),
        const HistoryPage(),
        const BookingPage(),
        const ProfilePage(),
      ];

  @override
  void initState() {
    super.initState();
    _checkProfileCompleteness();
  }

  void _checkProfileCompleteness() async {
    final userBloc = context.read<UserBloc>().state;
    if (userBloc is UserLoadSuccess) {
      final userId = userBloc.userId;
      if (userId != null && userId.isNotEmpty) {
        final customer = await CustomerService().getCustomerByUserId(userId);
        if (customer != null) {
          final bool isProfileIncomplete = (customer.fullName == null || customer.fullName!.isEmpty) ||
              (customer.phone == null || customer.phone!.isEmpty) ||
              (customer.address == null || customer.address!.isEmpty) ||
              (customer.photos == null || customer.photos!.isEmpty);
          if (isProfileIncomplete) {
            if (mounted) {
              _showProfileIncompleteDialog();
            }
          }
        }
      }
    }
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Incomplete'),
          content: const Text('Please complete your profile before continuing.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedIndex = 3; // Redirect to ProfilePage tab
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleSearch(String query) {
    final lowerQuery = query.toLowerCase();
    int newIndex = _selectedIndex;

    if (lowerQuery.contains('home') || lowerQuery.contains('homepage')) {
      newIndex = 0;
    } else if (lowerQuery.contains('history')) {
      newIndex = 1;
    } else if (lowerQuery.contains('booking')) {
      newIndex = 2;
    } else if (lowerQuery.contains('profile')) {
      newIndex = 3;
    }

    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  final Color amberColor = Colors.amber;
  final Color blackColor = Colors.black;
  final Color ivoryWhite = Color(0xFFFFF8E1); // Putih gading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivoryWhite,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.black, // agar icon tetap terlihat
        unselectedItemColor: Colors.amber,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Homepage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
