import 'package:flutter/material.dart';
import 'package:aplikasiservicemotor/screens/register_screen.dart';

// ========== Warna Global Aplikasi ==========
const Color kAppYellowColor = Color(0xFFFDEB71); // Warna latar utama
const Color kAppRedColor = Color(0xFFD84315); // Warna latar konten bawah
const Color kButtonColor = Color(0xFF3A3A3A); // Warna tombol login
const Color kWhiteColor = Colors.white;
const Color kGreyColor = Colors.grey;
const Color kInputLabelColor = Colors.white70;
const Color kBlackColor = Colors.black;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk input email & password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Membersihkan controller saat widget dihancurkan
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ========== Fungsi untuk Login Pengguna ==========
  void _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Cetak input ke konsol (untuk debug)
    print('Email: $email');
    print('Password: $password');

    // ========== 🔥 Integrasi Firebase Auth ==========
    // Pastikan Anda sudah:
    // 1. Menambahkan firebase_core & firebase_auth di pubspec.yaml
    // 2. Menginisialisasi Firebase di main.dart
    //    await Firebase.initializeApp();
    //
    // Lalu import:
    // import 'package:firebase_auth/firebase_auth.dart';
    //
    // Hapus komentar di bawah ini untuk mengaktifkan login dengan Firebase
    //
    // try {
    //   UserCredential userCredential = await FirebaseAuth.instance
    //     .signInWithEmailAndPassword(email: email, password: password);
    //   // Navigasi ke halaman utama jika berhasil login
    //   Navigator.pushReplacementNamed(context, '/home');
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Login failed: ${e.toString()}')),
    //   );
    //   print('Login error: $e');
    // }

    // Untuk sementara, tampilkan pesan dummy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login button pressed!')),
    );
  }

  // ========== Komponen Input Field Reusable ==========
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(color: kInputLabelColor, fontSize: 14),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Icon(icon, color: kWhiteColor, size: 20),
            const SizedBox(width: 12.0),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                style: const TextStyle(color: kWhiteColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: kWhiteColor.withOpacity(0.5)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kWhiteColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kAppYellowColor),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== Tampilan Utama Login ==========
  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Hitung ukuran logo berdasarkan lebar & tinggi layar
    double logoContainerHeight = screenHeight * 0.3;
    double logoSize = screenWidth * 0.3;
    if (logoSize > logoContainerHeight * 0.8) {
      logoSize = logoContainerHeight * 0.8;
    }

    return Scaffold(
      backgroundColor: kAppYellowColor,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: IntrinsicHeight(
            child: Column(
              children: <Widget>[
                // ========== Bagian Atas: Logo ==========
                Container(
                  width: double.infinity,
                  height: logoContainerHeight,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      // Tambahkan border radius ke logo agar tidak terlalu lancip
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/app_logo.jpeg',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // ========== Bagian Bawah: Form Login ==========
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                    decoration: const BoxDecoration(
                      color: kAppRedColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Text(
                          'Sign In',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kWhiteColor),
                        ),
                        const SizedBox(height: 30),

                        // Input Email
                        _buildCustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'johndoe@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 25),

                        // Input Password
                        _buildCustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: '**********',
                          icon: Icons.lock_outline,
                          obscureText: true,
                        ),
                        const SizedBox(height: 40),

                        // Tombol Login
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kButtonColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                          onPressed: _loginUser, // Fungsi login dipanggil di sini
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: kWhiteColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Tautan ke halaman register
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4.0,
                          children: [
                            const Text(
                              "If you don't have any account?",
                              style: TextStyle(color: kWhiteColor, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                ' Click for register',
                                style: TextStyle(
                                  color: kBlackColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: kBlackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
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
