import 'package:flutter/material.dart';
import 'package:pitstop/admin/data_master/service/pages/service_page.dart';
import 'package:pitstop/auth/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'admin/admin_dashboard_page.dart';
// import 'admin/admin_sidebar.dart';
import 'admin/data_master/account/data_akun_page.dart';
import 'package:pitstop/admin/booking/booking_page.dart';
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
        body: Center(child: Text('History Page')),
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
              child:
                  AdminDashboardPage()), // Use pageBuilder instead of builder
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
              builder: (context, state) =>
                  const ServicePage(), // Placeholder, should create DataJenisServisPage
            ),
          ],
        ),
        GoRoute(
          path: 'data-booking',
          builder: (context, state) =>
              const BookingPage(), // BookingPage harus dibuat di lib/admin/booking/pages/booking_page.dart
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
        title: 'PitStop Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
