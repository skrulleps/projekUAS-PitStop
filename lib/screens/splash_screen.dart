// lib/screens/splash_screen.dart

// --- Import Library yang Dibutuhkan ---
import 'dart:async'; // Digunakan untuk membuat Timer
import 'package:flutter/material.dart'; // Fondasi untuk membangun UI dengan Flutter

// --- Import Halaman Lain ---
// Pastikan path ini benar dan sesuai dengan nama proyek Anda.
// Mengimpor LoginScreen untuk navigasi setelah splash selesai.
import 'package:aplikasiservicemotor/screens/login_screen.dart';

// --- Definisi Warna Global (Konstanta) ---
// Digunakan untuk konsistensi tampilan.
const Color kAppYellowColor = Color(0xFFFDEB71); // Warna latar kuning untuk splash screen
// const Color kAppLogoColor = Color(0xFFD84315); // Tidak digunakan lagi karena logo berupa gambar

// --- Widget SplashScreen (StatefulWidget) ---
// StatefulWidget digunakan karena kita memerlukan state untuk mengelola Timer
// dan melakukan navigasi setelah durasi tertentu.
class SplashScreen extends StatefulWidget {
  // Konstruktor untuk SplashScreen.
  // 'super.key' meneruskan parameter key ke parent class (StatefulWidget).
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// --- State untuk SplashScreen ---
class _SplashScreenState extends State<SplashScreen> {

  // --- Lifecycle Method: initState ---
  // Metode ini dipanggil sekali ketika widget dan state-nya pertama kali dibuat
  // dan dimasukkan ke dalam widget tree.
  @override
  void initState() {
    super.initState(); // Selalu panggil super.initState() di awal.

    // --- Logika Timer untuk Durasi Splash Screen ---
    // Membuat Timer yang akan menjalankan fungsi callback setelah durasi tertentu (3 detik).
    // Di sini bisa juga dilakukan pengecekan awal ke backend, misalnya:
    // - Memeriksa status autentikasi pengguna (apakah sudah login sebelumnya).
    // - Mengambil data konfigurasi awal dari server.
    // Jika ada proses backend, navigasi akan dilakukan setelah proses tersebut selesai.
    Timer(const Duration(seconds: 3), () {
      // Setelah 3 detik, ganti halaman SplashScreen dengan LoginScreen.
      // Navigator.pushReplacement digunakan agar pengguna tidak bisa kembali
      // ke SplashScreen dengan menekan tombol "back".
      if (mounted) { // Pastikan widget masih ada di tree sebelum melakukan navigasi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  // --- Lifecycle Method: build ---
  // Metode ini dipanggil untuk membangun (merender) UI dari widget.
  // Dipanggil setiap kali ada perubahan state atau ketika Flutter perlu menggambar ulang widget.
  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk membantu layout yang responsif (opsional untuk splash ini)
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // Menentukan ukuran logo secara eksplisit
    const double logoSize = 200.0;

    // Scaffold adalah struktur dasar untuk halaman Material Design.
    // Menyediakan AppBar, Body, FloatingActionButton, dll.
    return Scaffold(
      // Mengatur warna latar belakang halaman.
      backgroundColor: kAppYellowColor,
      // Body adalah konten utama dari Scaffold.
      body: Center( // Center digunakan untuk memposisikan child-nya di tengah layar.
        // --- Menampilkan Logo Aplikasi dengan Sudut Melengkung ---
        child: ClipRRect( // Widget untuk membuat sudut child-nya menjadi melengkung.
          borderRadius: BorderRadius.circular(20.0), // Atur radius sesuai keinginan (misal: 15.0, 20.0, 25.0)
          child: Image.asset(
            'assets/images/app_logo.jpeg', // Path ke file gambar logo Anda.
            // Pastikan aset ini sudah didaftarkan di pubspec.yaml.
            width: logoSize,  // Lebar gambar logo.
            height: logoSize, // Tinggi gambar logo.
            // Properti 'fit' mengatur bagaimana gambar ditampilkan dalam batas ukuran yang diberikan:
            // - BoxFit.contain: Seluruh gambar terlihat, mungkin ada ruang kosong.
            // - BoxFit.cover: Mengisi area, menjaga rasio aspek, mungkin ada bagian gambar terpotong.
            // - BoxFit.fill: Mengisi area, tidak menjaga rasio aspek (gambar bisa terdistorsi).
            // - Dll.
            fit: BoxFit.cover, // BoxFit.cover sering terlihat baik dengan sudut melengkung.
            // Sesuaikan dengan preferensi dan bentuk logo Anda.
          ),
        ),
      ),
    );
  }
}