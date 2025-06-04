import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';

class HomepageContent extends StatelessWidget {
  const HomepageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color blackColor = Colors.black;
    final Color amberColor = Colors.amber.shade600;

    return Container(
      color: blackColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              String username = 'User';
              if (state is UserLoadSuccess) {
                username = state.username ?? 'User';
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to the homepage!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            },
=======
import 'package:pitstop/home/bloc/user_bloc.dart'; // Pastikan path ini sesuai dengan struktur proyek Anda
import 'package:pitstop/home/bloc/user_state.dart'; // Pastikan path ini sesuai dengan struktur proyek Anda

// HomepageContent adalah widget StatelessWidget yang bertanggung jawab untuk menampilkan
// seluruh konten utama di halaman beranda.
class HomepageContent extends StatelessWidget {
  const HomepageContent({Key? key}) : super(key: key);

  // Helper method untuk membuat header sebuah bagian,
  // contohnya "Categories" dengan tombol "View All" di sebelahnya.
  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menyebar title dan tombol View All
      children: [
        // Teks Judul Bagian
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // Tombol Teks "View All"
        TextButton(
          onPressed: onViewAll, // Aksi yang dijalankan ketika tombol ditekan
          child: Text(
            'View All',
            style: TextStyle(color: Colors.amber.shade700, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Helper method untuk membuat satu item kategori.
  // Menerima Icon, label teks, warna latar ikon, dan warna ikon.
  Widget _buildCategoryItem(BuildContext context, IconData iconData, String label, Color iconBgColor, Color iconColor) {
    return GestureDetector( // Membuat item bisa di-tap
      onTap: () {
        // TODO: Implementasi aksi ketika item kategori di-tap
        print('$label category tapped');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, // Kolom mengambil tinggi minimal yang dibutuhkan
        children: [
          // Lingkaran untuk latar belakang ikon
          CircleAvatar(
            radius: 30, // Ukuran lingkaran
            backgroundColor: iconBgColor, // Warna latar dari parameter
            child: Icon(iconData, size: 28, color: iconColor), // Ikon dari parameter
          ),
          const SizedBox(height: 8), // Spasi antara ikon dan label
          // Label teks kategori
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Helper method untuk membuat satu kartu (card) untuk informasi bengkel.
  Widget _buildGarageCard(
      BuildContext context,
      String imageUrl,    // URL gambar bengkel
      String name,        // Nama bengkel
      String address,     // Alamat bengkel
      double rating,      // Rating bengkel
      bool isOpen,        // Status buka/tutup bengkel
      ) {
    return Card(
      margin: const EdgeInsets.only(right: 16), // Margin kanan untuk spasi antar kartu di ListView horizontal
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Sudut kartu melengkung
      elevation: 3, // Efek bayangan kartu
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.65, // Lebar kartu sekitar 65% dari lebar layar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Teks dan elemen rata kiri
          children: [
            Stack( // Digunakan untuk menumpuk tag "Open" di atas gambar
              children: [
                // Gambar bengkel dengan sudut atas melengkung
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    imageUrl, // URL gambar dari parameter
                    height: 120, // Tinggi gambar
                    width: double.infinity, // Lebar gambar mengisi kartu
                    fit: BoxFit.cover, // Gambar di-crop agar pas
                    // Widget yang ditampilkan jika gambar gagal dimuat
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                    ),
                  ),
                ),
                // Tag "Open" jika bengkel buka
                if (isOpen)
                  Positioned( // Diposisikan di kanan atas gambar
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600, // Latar hijau untuk status "Open"
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Open',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            // Padding untuk konten teks di bawah gambar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Bengkel
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1, // Maksimal 1 baris
                    overflow: TextOverflow.ellipsis, // Tampilkan "..." jika teks terlalu panjang
                  ),
                  const SizedBox(height: 4),
                  // Alamat Bengkel
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded( // Agar teks alamat bisa mengambil sisa ruang dan menampilkan ellipsis jika panjang
                        child: Text(
                          address,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Rating Bengkel
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 16), // Ikon bintang
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(), // Teks rating
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Definisi warna-warna yang sering digunakan dalam widget ini
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color accentColor = Colors.amber.shade700; // Warna aksen utama (kuning/amber)
    final Color lightIconBg = Colors.amber.shade50; // Warna latar belakang terang untuk ikon kategori

    // Container utama untuk seluruh konten homepage.
    // Diberi warna latar putih.
    return Container(
      color: Colors.white,
      child: SafeArea( // Memastikan konten tidak tertimpa oleh status bar atau notch
        child: SingleChildScrollView( // Memungkinkan seluruh konten di-scroll jika melebihi tinggi layar
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding atas dan bawah untuk seluruh konten scrollable
            child: Column( // Menyusun semua bagian secara vertikal
              crossAxisAlignment: CrossAxisAlignment.start, // Konten dalam kolom rata kiri
              children: [
                // --- Bagian Header ---
                // Padding horizontal untuk bagian header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Item dalam Row rata atas
                    children: [
                      // Kolom untuk salam dan lokasi (mengambil sisa ruang)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Menggunakan BlocBuilder untuk mendapatkan nama pengguna secara dinamis
                            BlocBuilder<UserBloc, UserState>(
                              builder: (context, state) {
                                String username = 'User'; // Nama default jika state tidak berhasil dimuat
                                if (state is UserLoadSuccess) {
                                  username = state.username ?? 'User'; // Ambil username dari state
                                }
                                return Text(
                                  'Hello, $username 👋', // Salam dengan emoji
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 4), // Spasi kecil
                            // Widget InkWell membuat Row lokasi bisa di-tap
                            InkWell(
                              onTap: () {
                                // TODO: Implementasi aksi ketika lokasi di-tap
                                print('Location tapped!');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // Row hanya mengambil lebar yang dibutuhkan
                                children: [
                                  Icon(Icons.location_on_outlined, color: accentColor, size: 16), // Ikon lokasi
                                  const SizedBox(width: 4),
                                  Text('AL, Karama', style: TextStyle(fontSize: 14, color: secondaryTextColor)), // Teks lokasi (statis)
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down_outlined, color: secondaryTextColor, size: 16), // Ikon panah bawah
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tombol Ikon untuk notifikasi
                      IconButton(
                        icon: Icon(Icons.notifications_none_outlined, color: primaryTextColor, size: 28),
                        onPressed: () {
                          // TODO: Implementasi aksi ketika ikon notifikasi di-tap
                          print('Notification bell tapped!');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Spasi antar bagian

                // --- Search Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding horizontal untuk search bar
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search here', // Teks placeholder
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600), // Ikon pencarian di kiri
                      filled: true, // Memberi warna latar pada field
                      fillColor: Colors.grey.shade100, // Warna latar field (abu-abu muda)
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0), // Padding dalam field
                      // Border standar ketika field tidak fokus atau enable
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), // Sudut melengkung penuh
                        borderSide: BorderSide.none, // Tidak ada border luar jika menggunakan fillColor
                      ),
                      // Border ketika field enable (bisa diganti jika ingin ada border terlihat)
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0), // Border abu-abu tipis
                      ),
                      // Border ketika field sedang fokus (diketik)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: accentColor, width: 1.5), // Border warna aksen
                      ),
                    ),
                    onSubmitted: (value) {
                      // TODO: Implementasi logika pencarian ketika user menekan enter/submit
                      print('Search submitted: $value');
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // --- Special Offer Banner ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Sudut banner melengkung
                    clipBehavior: Clip.antiAlias, // Memastikan konten (gambar) terpotong sesuai bentuk Card
                    elevation: 4, // Efek bayangan banner
                    child: Stack( // Menumpuk gambar, gradasi, dan konten teks/tombol
                      alignment: Alignment.centerLeft, // Konten teks rata kiri tengah
                      children: [
                        // Gambar Latar Banner
                        Image.network(
                          'https://images.unsplash.com/photo-1553524032-99cecafa2a6c?q=80&w=1000&auto=format&fit=crop', // GANTI DENGAN URL GAMBAR ANDA
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover, // Gambar memenuhi area banner
                          // Penanganan jika gambar gagal dimuat
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                          ),
                        ),
                        // Overlay Gradasi Gelap di atas gambar (agar teks lebih mudah dibaca)
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.transparent],
                                begin: Alignment.centerLeft, // Gradasi dari kiri
                                end: Alignment.centerRight,   // ke kanan
                                stops: const [0.0, 0.7, 1.0], // Distribusi warna gradasi
                              )
                          ),
                        ),
                        // Konten Teks dan Tombol di atas Banner
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
                            mainAxisAlignment: MainAxisAlignment.center, // Vertikal di tengah (jika Stack mengizinkan)
                            children: [
                              const Text(
                                'Get special offer',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Up to 25%',
                                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implementasi aksi ketika tombol "Explore Now" ditekan
                                  print('Explore Now banner tapped!');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87, // Warna tombol
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Sudut tombol melengkung
                                ),
                                child: const Text('Explore Now', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Categories Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionHeader(context, "Categories", () {
                    // TODO: Implementasi navigasi ke halaman "View All Categories"
                    print('View All Categories tapped');
                  }),
                ),
                const SizedBox(height: 16),
                // Daftar Kategori (menggunakan Row karena jumlahnya sedikit dan tetap)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menyebar item kategori secara merata
                    children: [
                      // Menggunakan helper method _buildCategoryItem untuk setiap kategori
                      // GANTI DENGAN IKON DAN DATA KATEGORI ANDA
                      _buildCategoryItem(context, Icons.directions_car_filled_outlined, 'Car', lightIconBg, accentColor),
                      _buildCategoryItem(context, Icons.local_gas_station_outlined, 'Oil', lightIconBg, accentColor),
                      _buildCategoryItem(context, Icons.settings_outlined, 'Engine', lightIconBg, accentColor),
                      _buildCategoryItem(context, Icons.wash_outlined, 'Washing', lightIconBg, accentColor),
                    ],
                  ),
                ),
                const SizedBox(height: 28), // Spasi lebih besar sebelum bagian berikutnya

                // --- Nearby Garage Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSectionHeader(context, "Nearby Garage", () {
                    // TODO: Implementasi navigasi ke halaman "View All Nearby Garages"
                    print('View All Nearby Garage tapped');
                  }),
                ),
                const SizedBox(height: 16),
                // Container dengan tinggi tetap untuk ListView horizontal
                SizedBox(
                  height: 235, // Sesuaikan tinggi ini agar kartu bengkel terlihat baik
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Scroll ke samping
                    padding: const EdgeInsets.only(left: 16.0), // Padding kiri untuk item pertama agar tidak terlalu mepet
                    itemCount: 3, // GANTI DENGAN JUMLAH BENGKEL SEBENARNYA ATAU DARI API
                    itemBuilder: (context, index) {
                      // Data dummy untuk bengkel. GANTI DENGAN DATA DINAMIS DARI BACKEND/API Anda.
                      final garages = [
                        {
                          'name': 'Supreme Service Center',
                          'address': '1012 Ocean Avenue, New...',
                          'rating': 4.2,
                          'isOpen': true,
                          'imageUrl': 'https://images.unsplash.com/photo-1629977030476-8f4d7e9eb755?q=80&w=1000&auto=format&fit=crop' // GANTI GAMBAR
                        },
                        {
                          'name': 'Gearheads Auto Repair',
                          'address': '1012 Ocean Avenue, New...',
                          'rating': 4.5,
                          'isOpen': false,
                          'imageUrl': 'https://images.unsplash.com/photo-1581490215830-872703600734?q=80&w=1000&auto=format&fit=crop' // GANTI GAMBAR
                        },
                        {
                          'name': 'QuickFix Motors',
                          'address': '789 Service Rd, Townsville',
                          'rating': 4.0,
                          'isOpen': true,
                          'imageUrl': 'https://images.unsplash.com/photo-1599252628936-5ead47b27647?q=80&w=1000&auto=format&fit=crop' // GANTI GAMBAR
                        },
                      ];
                      // Menggunakan helper method _buildGarageCard untuk setiap item bengkel
                      return _buildGarageCard(
                        context,
                        garages[index]['imageUrl'] as String,
                        garages[index]['name'] as String,
                        garages[index]['address'] as String,
                        garages[index]['rating'] as double,
                        garages[index]['isOpen'] as bool,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24), // Padding tambahan di bagian bawah scroll
              ],
            ),
>>>>>>> view2
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> view2
