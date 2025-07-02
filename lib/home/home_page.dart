import 'package:flutter/material.dart';
import 'package:pitstop/home/profile_page.dart';
import 'package:pitstop/home/booking_page.dart';
import 'package:pitstop/home/history_page.dart';
import 'homepage_content.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/utils/profile_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

List<Widget> get _pages => [
        HomepageContent(
          onSearchSubmitted: _handleSearch,
          onNavigateToBooking: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
        ),
        const HistoryPage(),
        BookingPage(
          onRequestProfileTab: () {
            setState(() {
              _selectedIndex = 3;
            });
          },
        ),
        const ProfilePage(),
      ];

  @override
  void initState() {
    super.initState();
    _checkProfileCompleteness();
  }

  void _checkProfileCompleteness() async {
    final isIncomplete = await checkProfileCompleteness(context);
    if (isIncomplete && mounted) {
      showProfileIncompleteDialog(context, () {
        setState(() {
          _selectedIndex = 3; // Redirect to ProfilePage tab
        });
      });
    }
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
