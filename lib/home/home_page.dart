import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'profile_page.dart';
import 'homepage_content.dart';
=======
import 'package:pitstop/home/profile_page.dart';
import 'homepage_content.dart';
import 'history_page.dart';
import 'booking_page.dart';
import 'profile_page2.dart'; // TAMBAHKAN IMPORT INI (sesuaikan path jika perlu)
>>>>>>> view2

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

<<<<<<< HEAD
  static final List<Widget> _pages = <Widget>[
    const HomepageContent(),
    const Center(child: Text('History')),
    const Center(child: Text('Booking')),
    const Center(child: Text('Profile'),),
=======
  // Daftar halaman yang akan ditampilkan berdasarkan item navigasi yang dipilih
  static final List<Widget> _pages = <Widget>[
    const HomepageContent(),        // Index 0: Halaman Utama
    const HistoryPage(),            // Index 1: Halaman History
    const BookingPage(),            // Index 2: Halaman Booking
    const ProfilePage(),            // Index 3: Halaman Profil <<< PERUBAHAN DI SINI
>>>>>>> view2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

<<<<<<< HEAD
  final Color amberColor = Colors.amber;
  final Color blackColor = Colors.black;
  final Color ivoryWhite = Color(0xFFFFF8E1); // Putih gading
=======
  // Definisi Warna
  final Color amberColor = Colors.amber;
  final Color blackColor = Colors.black;
  final Color ivoryWhite = Color(0xFFFFF8E1);
>>>>>>> view2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivoryWhite,
<<<<<<< HEAD
      body: _pages[_selectedIndex],
=======
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
>>>>>>> view2
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: blackColor,
        selectedItemColor: amberColor,
        unselectedItemColor: amberColor.withOpacity(0.7),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
<<<<<<< HEAD
=======
        type: BottomNavigationBarType.fixed,
>>>>>>> view2
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
<<<<<<< HEAD
}
=======
}
>>>>>>> view2
