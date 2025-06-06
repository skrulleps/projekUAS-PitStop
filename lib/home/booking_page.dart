import 'package:flutter/material.dart';

// Model sederhana untuk data item booking
class BookingEntry {
  final String id;
  final String imageUrl;
  final String garageName;
  final String addressSnippet;
  final String bookingRef;
  final double garageRating;
  final String status; // "Ongoing", "Completed", "Canceled"

  const BookingEntry({
    required this.id,
    required this.imageUrl,
    required this.garageName,
    required this.addressSnippet,
    required this.bookingRef,
    required this.garageRating,
    required this.status,
  });
}

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data contoh
  static const List<BookingEntry> _allBookings = [
    BookingEntry(
      id: 'B001',
      imageUrl: 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?q=80&w=1000&auto=format&fit=crop', // Ganti dengan URL gambar Anda
      garageName: 'Adinath Garage',
      addressSnippet: 'Old Ghod Dod Rd, Ram Chowk,...',
      bookingRef: '#45889785',
      garageRating: 3.5,
      status: 'Ongoing',
    ),
    BookingEntry(
      id: 'B002',
      imageUrl: 'https://images.unsplash.com/photo-1629977030476-8f4d7e9eb755?q=80&w=1000&auto=format&fit=crop', // Ganti dengan URL gambar Anda
      garageName: 'Gearheads Service Center',
      addressSnippet: '1012 Ocean avanue, New...',
      bookingRef: '#52145624',
      garageRating: 4.2, // Rating bengkel
      status: 'Ongoing',
    ),
    BookingEntry(
      id: 'B003',
      imageUrl: 'https://images.unsplash.com/photo-1581490215830-872703600734?q=80&w=1000&auto=format&fit=crop', // Ganti dengan URL gambar Anda
      garageName: 'Shree Sai Auto Care Ceram...',
      addressSnippet: 'Shop No. 2,3 sarjan Complex,...',
      bookingRef: '#78525688',
      garageRating: 3.8,
      status: 'Completed',
    ),
    BookingEntry(
      id: 'B004',
      imageUrl: 'https://images.unsplash.com/photo-1599252628936-5ead47b27647?q=80&w=1000&auto=format&fit=crop', // Ganti dengan URL gambar Anda
      garageName: 'QuickFix Motors',
      addressSnippet: 'Jl. Servis Cepat No. 12',
      bookingRef: '#12345678',
      garageRating: 4.0,
      status: 'Completed',
    ),
    BookingEntry(
      id: 'B005',
      imageUrl: 'https://images.unsplash.com/photo-1506521781263-d5449e827895?q=80&w=1000&auto=format&fit=crop', // Ganti dengan URL gambar Anda
      garageName: 'AutoPro Clinic',
      addressSnippet: 'Jl. Montir Handal Kav. 5',
      bookingRef: '#98765432',
      garageRating: 4.5,
      status: 'Canceled',
    ),
  ];

  List<BookingEntry> _getFilteredBookings(String status) {
    return _allBookings.where((booking) => booking.status == status).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildBookingCard(BuildContext context, BookingEntry booking) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    booking.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.business_outlined, size: 40, color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.garageName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.addressSnippet,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.bookingRef,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Row( // Rating di pojok kanan
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      booking.garageRating.toString(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implementasi aksi lihat detail booking
                print('View Detail tapped for ${booking.bookingRef}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade50, // Warna latar tombol yang lembut
                foregroundColor: Colors.amber.shade800, // Warna teks tombol
                elevation: 0, // Tidak ada bayangan untuk tombol
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('View Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<BookingEntry> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada booking dengan status ini.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(context, bookings[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Booking',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Latar AppBar putih
        elevation: 1, // Sedikit bayangan
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber.shade800, // Warna teks tab yang aktif
          unselectedLabelColor: Colors.grey.shade600, // Warna teks tab yang tidak aktif
          indicatorColor: Colors.amber.shade800, // Warna indikator tab
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(_getFilteredBookings('Ongoing')),
          _buildBookingList(_getFilteredBookings('Completed')),
          _buildBookingList(_getFilteredBookings('Canceled')),
        ],
      ),
    );
  }
}