import 'package:flutter/material.dart';
import 'package:pitstop/home/profile_page.dart';
import 'package:pitstop/home/booking_page.dart';
import 'package:pitstop/home/history_page.dart';
import 'homepage_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomepageContent(),
    const HistoryPage(),
    const BookingPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        backgroundColor: blackColor,
        selectedItemColor: amberColor,
        unselectedItemColor: amberColor.withOpacity(0.7),
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
