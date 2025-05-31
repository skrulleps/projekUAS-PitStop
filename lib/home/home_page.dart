import 'package:flutter/material.dart';
import 'package:pitstop/home/profile_page.dart';
import 'homepage_content.dart';
import 'history_page.dart';
import 'booking_page.dart';
import 'profile_page2.dart'; // TAMBAHKAN IMPORT INI (sesuaikan path jika perlu)

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan berdasarkan item navigasi yang dipilih
  static final List<Widget> _pages = <Widget>[
    const HomepageContent(),        // Index 0: Halaman Utama
    const HistoryPage(),            // Index 1: Halaman History
    const BookingPage(),            // Index 2: Halaman Booking
    const ProfilePage(),            // Index 3: Halaman Profil <<< PERUBAHAN DI SINI
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Definisi Warna
  final Color amberColor = Colors.amber;
  final Color blackColor = Colors.black;
  final Color ivoryWhite = Color(0xFFFFF8E1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivoryWhite,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: blackColor,
        selectedItemColor: amberColor,
        unselectedItemColor: amberColor.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
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