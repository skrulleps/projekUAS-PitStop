import 'package:flutter/material.dart';
// Pastikan path ini sesuai dengan nama proyek Anda
// Import halaman LoginScreen untuk navigasi kembali jika pengguna sudah punya akun.
import 'package:aplikasiservicemotor/screens/login_screen.dart';

// --- Definisi Warna Global (Konstanta) ---
// Digunakan untuk konsistensi tampilan di seluruh aplikasi.
const Color kAppYellowColor = Color(0xFFFDEB71); // Warna kuning utama aplikasi
const Color kAppRedColor = Color(0xFFD84315);   // Warna merah untuk kontainer form
const Color kButtonColor = Color(0xFF3A3A3A);   // Warna untuk tombol
const Color kWhiteColor = Colors.white;        // Warna putih
const Color kGreyColor = Colors.grey;          // Warna abu-abu
const Color kInputLabelColor = Colors.white70; // Warna untuk label di atas input field
const Color kBlackColor = Colors.black;        // Warna hitam, digunakan untuk link

// --- Widget Halaman Registrasi ---
// StatefulWidget karena kita akan mengelola state dari TextEditingController.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- Controller untuk Input Fields ---
  // Digunakan untuk mengambil dan mengelola teks yang dimasukkan pengguna.
  // Setiap TextField memiliki controllernya sendiri.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Lifecycle Method: dispose ---
  // Dipanggil ketika widget dan state-nya dihapus dari tree.
  // Penting untuk melepaskan resource yang digunakan oleh controller
  // untuk mencegah kebocoran memori (memory leaks).
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Fungsi untuk Proses Registrasi Pengguna ---
  // Fungsi ini akan dipanggil ketika tombol "Submit" ditekan.
  // Di sinilah logika untuk backend (misalnya Firebase) akan ditempatkan.
  void _registerUser() {
    // 1. Ambil data dari input fields menggunakan controller.
    final String username = _usernameController.text.trim(); // .trim() untuk menghapus spasi di awal/akhir
    final String email = _emailController.text.trim();
    final String password = _passwordController.text; // Password biasanya tidak di-trim

    // 2. (Opsional) Validasi Input Sederhana di Frontend
    //    Sebelum mengirim ke backend, Anda bisa melakukan validasi dasar.
    //    Misalnya, memastikan field tidak kosong, email berformat valid, password cukup kuat.
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi!')),
      );
      return; // Hentikan proses jika ada field kosong
    }
    // Tambahkan validasi lain jika perlu (mis. format email, panjang password)

    // 3. Tampilkan data di konsol (untuk debugging saat ini).
    //    Ini akan digantikan dengan logika backend.
    print('--- Proses Registrasi Dimulai ---');
    print('Username: $username');
    print('Email: $email');
    print('Password: $password'); // HATI-HATI: Jangan print password di aplikasi produksi!

    // --- TITIK INTEGRASI BACKEND (Contoh Firebase Authentication) ---
    // Di sini Anda akan memanggil fungsi Firebase untuk membuat pengguna baru.
    // try {
    //   // Contoh menggunakan Firebase Authentication:
    //   // UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //   //   email: email,
    //   //   password: password,
    //   // );
    //
    //   // Jika berhasil, Anda mungkin ingin menyimpan username ke Firestore atau Realtime Database
    //   // if (userCredential.user != null) {
    //   //   await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
    //   //     'username': username,
    //   //     'email': email,
    //   //     // Tambahkan field lain jika perlu
    //   //   });
    //   //   print('Pengguna berhasil dibuat: ${userCredential.user!.uid}');
    //   //   ScaffoldMessenger.of(context).showSnackBar(
    //   //     const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
    //   //   );
    //   //   // Arahkan ke halaman login atau halaman utama
    //   //   if (mounted) Navigator.pushReplacementNamed(context, '/login'); // Ganti dengan rute login Anda
    //   // }
    // } on FirebaseAuthException catch (e) {
    //   // Tangani error dari Firebase (misalnya, email sudah digunakan, password lemah)
    //   print('Error Registrasi Firebase: ${e.message}');
    //   String errorMessage = 'Terjadi kesalahan saat registrasi.';
    //   if (e.code == 'weak-password') {
    //     errorMessage = 'Password yang diberikan terlalu lemah.';
    //   } else if (e.code == 'email-already-in-use') {
    //     errorMessage = 'Alamat email ini sudah terdaftar.';
    //   } else if (e.code == 'invalid-email') {
    //     errorMessage = 'Format email tidak valid.';
    //   }
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(errorMessage)),
    //   );
    // } catch (e) {
    //   // Tangani error umum lainnya
    //   print('Error Umum: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Terjadi kesalahan. Coba lagi nanti.')),
    //   );
    // }
    // --- AKHIR TITIK INTEGRASI BACKEND ---

    // Placeholder untuk UI feedback saat ini
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tombol Submit ditekan! (Integrasi backend belum ada)')),
    );
  }

  // --- Fungsi Helper untuk Membangun TextField Kustom ---
  // Membuat widget input field yang seragam (label, ikon, input).
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Label rata kiri
      children: [
        // Label teks di atas input field
        Text(
          labelText,
          style: const TextStyle(
            color: kInputLabelColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8.0), // Jarak antara label dan input
        // Baris untuk ikon dan input field
        Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Sejajarkan ikon dan input field secara vertikal
          children: [
            Icon(icon, color: kWhiteColor, size: 20), // Ikon di sebelah kiri
            const SizedBox(width: 12.0), // Jarak antara ikon dan TextField
            // TextField dibungkus Expanded agar mengisi sisa ruang horizontal
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText, // Untuk menyembunyikan input password
                keyboardType: keyboardType, // Menentukan jenis keyboard (email, angka, dll.)
                style: const TextStyle(color: kWhiteColor, fontSize: 16), // Gaya teks inputan pengguna
                decoration: InputDecoration(
                  hintText: hintText, // Teks petunjuk di dalam field
                  hintStyle: TextStyle(color: kWhiteColor.withOpacity(0.5)), // Gaya teks petunjuk
                  // Garis bawah untuk input field
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kWhiteColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kAppYellowColor), // Warna garis bawah saat field aktif
                  ),
                  isDense: true, // Membuat TextField lebih ramping secara vertikal
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0), // Padding di dalam TextField
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Lifecycle Method: build ---
  // Metode ini dipanggil untuk membangun UI widget.
  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk layout yang lebih responsif
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // Menghitung tinggi container logo (misalnya, 25% dari tinggi layar)
    double logoContainerHeight = screenHeight * 0.25;
    // Menghitung ukuran logo (misalnya, 28% dari lebar layar)
    double logoSize = screenWidth * 0.28;

    // Memastikan ukuran logo tidak melebihi 80% tinggi container-nya
    if (logoSize > logoContainerHeight * 0.8) {
      logoSize = logoContainerHeight * 0.8;
    }

    // Scaffold adalah struktur dasar halaman Material Design
    return Scaffold(
      backgroundColor: kAppYellowColor, // Latar belakang utama halaman berwarna kuning
      // SingleChildScrollView memungkinkan konten di-scroll jika lebih panjang dari layar
      body: SingleChildScrollView(
        // ConstrainedBox memastikan child memiliki tinggi minimal setinggi layar,
        // membantu agar footer (jika ada) atau bagian bawah tetap di posisinya.
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          // IntrinsicHeight membantu Column dengan Expanded child di dalamnya untuk
          // menyesuaikan ukurannya dengan benar dalam konteks scrollable.
          child: IntrinsicHeight(
            // Column utama yang menyusun halaman secara vertikal
            child: Column(
              children: <Widget>[
                // --- Bagian Atas: Logo Aplikasi ---
                Container(
                  width: double.infinity, // Lebar penuh
                  height: logoContainerHeight, // Tinggi yang sudah dihitung
                  alignment: Alignment.center, // Logo di tengah container
                  // color: kAppYellowColor, // Tidak perlu karena Scaffold sudah kuning
                  child: Padding(
                    padding: const EdgeInsets.all(12.0), // Jarak logo dari tepi container
                    // ClipRRect untuk memberikan sudut melengkung pada gambar logo
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0), // Radius lengkungan
                      child: Image.asset(
                        'assets/images/app_logo.jpeg', // Path ke file logo Anda
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.cover, // Cara gambar mengisi area yang tersedia
                      ),
                    ),
                  ),
                ),
                // --- Bagian Bawah: Form Registrasi (Merah) ---
                // Expanded memastikan container ini mengisi sisa ruang vertikal
                Expanded(
                  child: Container(
                    width: double.infinity, // Lebar penuh
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 30), // Padding dalam container
                    // Dekorasi untuk warna latar merah dan sudut atas melengkung
                    decoration: const BoxDecoration(
                      color: kAppRedColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    // Column untuk elemen-elemen di dalam form
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Elemen mengisi lebar
                      // mainAxisSize: MainAxisSize.min, // Dihapus agar bisa mengisi Expanded
                      children: <Widget>[
                        // Judul Form
                        const Text(
                          'Register',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: kWhiteColor,
                          ),
                        ),
                        const SizedBox(height: 30), // Spasi vertikal

                        // Input field untuk Username
                        _buildCustomTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          hintText: 'contoh: budi123',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 25),

                        // Input field untuk Email
                        _buildCustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'anda@contoh.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 25),

                        // Input field untuk Password
                        _buildCustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'minimal 6 karakter',
                          icon: Icons.lock_outline,
                          obscureText: true, // Sembunyikan teks password
                        ),
                        const SizedBox(height: 40),

                        // Tombol Submit Registrasi
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kButtonColor, // Warna tombol
                            padding: const EdgeInsets.symmetric(vertical: 15), // Padding tombol
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Sudut tombol melengkung
                            ),
                          ),
                          onPressed: _registerUser, // Panggil fungsi _registerUser saat ditekan
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18, color: kWhiteColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Link untuk navigasi ke halaman Login jika sudah punya akun
                        Wrap( // Gunakan Wrap agar teks bisa turun baris jika tidak muat
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4.0, // Spasi horizontal antar teks
                          children: [
                            const Text(
                              'If you have account?',
                              style: TextStyle(color: kWhiteColor, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigasi kembali ke halaman Login
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context); // Kembali ke layar sebelumnya jika ada
                                } else {
                                  // Jika tidak ada layar sebelumnya (misalnya, ini halaman pertama),
                                  // ganti dengan LoginScreen.
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const LoginScreen()));
                                }
                              },
                              child: const Text(
                                ' Click for login',
                                style: TextStyle(
                                  color: kBlackColor, // Warna teks link hitam
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline, // Garis bawah
                                  decorationColor: kBlackColor, // Warna garis bawah hitam
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Spacer(), // Bisa ditambahkan jika ingin mendorong konten ke atas
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}