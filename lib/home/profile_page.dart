import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Helper widget untuk membuat setiap item menu di halaman profil
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor, // Warna ikon bisa disesuaikan
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 1.5, // Sedikit bayangan agar terlihat lebih menonjol
      child: InkWell( // Membuat item bisa di-tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? Colors.grey.shade700, size: 24), // Ikon di kiri
              const SizedBox(width: 16.0), // Spasi antara ikon dan teks
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey.shade500), // Ikon panah di kanan
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color amberColor = Colors.amber.shade600; // Digunakan untuk ikon kamera

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang utama halaman putih
      body: SafeArea( // Memastikan konten tidak tertimpa status bar
        child: SingleChildScrollView( // Agar konten bisa di-scroll jika panjang
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan elemen di tengah secara horizontal
            children: <Widget>[
              const SizedBox(height: 30.0), // Spasi dari atas
              // Judul "My Profile"
              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30.0),
              // Foto Profil
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60, // Ukuran avatar lebih besar
                    backgroundColor: Colors.grey.shade200, // Warna latar jika tidak ada gambar
                    child: const Icon(
                      Icons.person, // Ikon placeholder
                      size: 70,
                      color: Colors.grey,
                    ),
                    // backgroundImage: NetworkImage('URL_FOTO_PROFIL_JIKA_ADA'), // Ganti dengan NetworkImage atau AssetImage jika ada gambar
                  ),
                  // Ikon kamera kecil untuk edit foto
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: amberColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(6.0), // Padding agar ikon tidak terlalu mepet
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              // Nama Pengguna (statis untuk desain)
              const Text(
                'Maria Sant',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30.0), // Spasi sebelum daftar menu

              // Daftar Menu
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                iconColor: Colors.blue.shade700,
                onTap: () {
                  print('Edit Profile tapped (design only)');
                  // Untuk navigasi nyata: context.push('/edit-profile');
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.bookmark_border,
                title: 'Bookmark',
                iconColor: Colors.orange.shade700,
                onTap: () {
                  print('Bookmark tapped (design only)');
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                iconColor: Colors.red.shade600,
                onTap: () {
                  print('Change Password tapped (design only)');
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                iconColor: Colors.green.shade700,
                onTap: () {
                  print('Privacy Policy tapped (design only)');
                },
              ),
              _buildProfileMenuItem(
                icon: Icons.logout,
                title: 'Sign Out',
                iconColor: Colors.grey.shade800,
                onTap: () {
                  print('Sign Out tapped (design only)');
                  // Untuk aksi nyata: panggil fungsi signOut dan navigasi
                },
              ),
              const SizedBox(height: 30.0), // Spasi di bawah
            ],
          ),
        ),
      ),
    );
  }
}