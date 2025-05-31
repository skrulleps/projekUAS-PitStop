import 'package:flutter/material.dart';
import 'package:pitstop/admin/data_master/service/pages/service_page.dart';
import 'package:pitstop/auth/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'admin/admin_dashboard_page.dart';
// import 'admin/admin_sidebar.dart';
import 'admin/data_master/account/data_akun_page.dart';
import 'package:pitstop/admin/booking/booking_page.dart'; // Pastikan ini adalah halaman list booking yang baru
import 'package:pitstop/admin/data_master/customer/customer_page.dart';
import 'admin/data_master/mechanic/mechanic_page.dart';
import 'admin/data_master/mechanic/pages/mechanic_form.dart';
import 'auth/login/login_page.dart';
import 'auth/register/register_page.dart';
import 'home/home_page.dart';
import 'package:pitstop/splash_screen.dart';
// import 'package:pitstop/home/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home/bloc/user_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Log environment for debugging
  print("SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}");
  print("SUPABASE_KEY: ${dotenv.env['SUPABASE_KEY']}");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
  );

  // Inisialisasi format tanggal lokal (sudah benar)
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('History Page')), // Placeholder
      ),
    ),
    // GoRoute(
    //   path: '/profile',
    //   builder: (context, state) => const ProfilePage(),
    // ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
      routes: [
        GoRoute(
          path: 'data-master',
          pageBuilder: (context, state) => const MaterialPage(
              child: AdminDashboardPage()),
          routes: [
            GoRoute(
              path: 'data-customer',
              builder: (context, state) => const CustomerPage(),
            ),
            GoRoute(
              path: 'data-mekanik',
              builder: (context, state) => const MechanicPage(),
              routes: [
                GoRoute(
                  path: 'form',
                  builder: (context, state) => const MechanicFormPage(),
                ),
              ],
            ),
            GoRoute(
              path: 'data-akun',
              builder: (context, state) => const DataAkunPage(),
            ),
            GoRoute(
              path: 'data-jenis-servis',
              builder: (context, state) => const ServicePage(),
            ),
          ],
        ),
        GoRoute(
          path: 'data-booking',
          builder: (context, state) => const BookingPage(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    return BlocProvider(
      create: (context) => UserBloc(authRepository: authRepository),
      child: MaterialApp.router(
        title: 'PitStop App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              primary: Colors.amber[700],
              secondary: Colors.blueGrey[600],
            ),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              // Di kode sebelumnya, backgroundColor: Theme.of(context).cardColor
              // ini bisa menyebabkan error jika cardColor belum terdefinisi atau jika Anda ingin warna solid.
              // Kita bisa set warna spesifik atau biarkan default Material 3.
              // backgroundColor: Colors.white, // Contoh warna solid
                elevation: 1,
                titleTextStyle: TextStyle(
                    color: Colors.grey[800], // Warna teks title AppBar
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                ),
                iconTheme: IconThemeData(color: Colors.grey[700]) // Warna ikon di AppBar
            ),
            // !!! PERBAIKAN DI SINI: CardTheme menjadi CardThemeData !!!
            cardTheme: CardThemeData(
                elevation: 2.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4)
            ),
            // !!! ---------------------------------------------------- !!!
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                )
            )
        ),
        routerConfig: _router,
      ),
    );
  }
}