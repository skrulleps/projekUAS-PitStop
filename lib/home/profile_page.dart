import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pitstop/admin/data_master/customer/pages/edit_customer_page.dart';
import 'package:pitstop/auth/auth_repository.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'package:pitstop/home/bloc/user_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<CustomerModel?>? _customerFuture;

  void _loadCustomers() {
    final userBloc = context.read<UserBloc>().state;
    if (userBloc is UserLoadSuccess) {
      final userId = userBloc.userId;
      // ignore: unnecessary_null_comparison
      if (userId != null && userId.isNotEmpty) {
        if (mounted) {
          setState(() {
            print('Loading customer data for userId: $userId');
            _customerFuture = CustomerService().getCustomerByUserId(userId);
          });
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_customerFuture == null) {
      _loadCustomers();
    }
  }

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
      child: InkWell(
        // Membuat item bisa di-tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(icon,
                  color: iconColor ?? Colors.grey.shade700,
                  size: 24), // Ikon di kiri
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
              Icon(Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Colors.grey.shade500), // Ikon panah di kanan
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color amberColor =
        Colors.amber.shade600; // Digunakan untuk ikon kamera

    return Scaffold(
        backgroundColor: Colors.white, // Latar belakang utama halaman putih
        body: SafeArea(
          // Memastikan konten tidak tertimpa status bar
          child: RefreshIndicator(
            onRefresh: () async {
              final userBloc = BlocProvider.of<UserBloc>(context);
              if (userBloc.state is UserLoadSuccess) {
                final userId = (userBloc.state as UserLoadSuccess).userId;
                // ignore: unnecessary_null_comparison
                if (userId != null && userId.isNotEmpty) {
                  setState(() {
                    _customerFuture =
                        CustomerService().getCustomerByUserId(userId);
                  });
                }
              }
            },
            child: SingleChildScrollView(
              // Agar konten bisa di-scroll jika panjang
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Pusatkan elemen di tengah secara horizontal
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
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      if (state is UserLoadSuccess) {
                        // ignore: unused_local_variable
                        final userId = state.userId;
                        return FutureBuilder<CustomerModel?>(
                          future: _customerFuture,
                          builder: (context, snapshot) {
                            print(
                                'FutureBuilder snapshot: connectionState=\${snapshot.connectionState}, hasData=\${snapshot.hasData}, data=\${snapshot.data}');
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text(
                                'Error loading profile',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              final customer = snapshot.data;
                              final fullName = customer?.fullName ?? 'User';
                              final photoPath = customer?.photos;
                              final photoUrl = photoPath != null &&
                                      photoPath.isNotEmpty
                                  ? CustomerService().getAvatarUrl(photoPath)
                                  : null;
                              return Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey.shade200,
                                        backgroundImage: photoUrl != null
                                            ? NetworkImage(photoUrl)
                                            : null,
                                        child: photoUrl == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 70,
                                                color: Colors.grey,
                                              )
                                            : null,
                                      ),
                                      Positioned(
                                        right: 4,
                                        bottom: 4,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: amberColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                          padding: const EdgeInsets.all(6.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              // Request permission and pick image from gallery
                                              final ImagePicker picker =
                                                  ImagePicker();
                                              final XFile? image =
                                                  await picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (image != null) {
                                                final file = File(image.path);
                                                final userBloc =
                                                    BlocProvider.of<UserBloc>(
                                                        context);
                                                // ignore: unused_local_variable
                                                final authRepository =
                                                    AuthRepository();
                                                if (userBloc.state
                                                    is UserLoadSuccess) {
                                                  final userId = (userBloc.state
                                                          as UserLoadSuccess)
                                                      .userId;
                                                  // ignore: unnecessary_null_comparison
                                                  if (userId != null) {
                                                    final customerService =
                                                        CustomerService();
                                                    final success =
                                                        await customerService
                                                            .uploadAvatar(file,
                                                                userId: userId);
                                                    if (success != null) {
                                                      // Refresh UI by triggering a state update or reload customer data
                                                      _customerFuture =
                                                          CustomerService()
                                                              .getCustomerByUserId(
                                                                  userId);
                                                      if (mounted) {
                                                        setState(() {});
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                              content: Text(
                                                                  'Foto berhasil di update')),
                                                        );
                                                      }
                                                    }
                                                  }
                                                }
                                              }
                                            },
                                            child: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    fullName,
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return const Text(
                                'User',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return const Text(
                          'User',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Nama Pengguna (statis untuk desain)
                  // Removed redundant full_name display
                  const SizedBox(height: 30.0), // Spasi sebelum daftar menu

                  // Daftar Menu
                  _buildProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    iconColor: Colors.blue.shade700,
                    onTap: () {
                      final userState = context.read<UserBloc>().state;
                      if (userState is UserLoadSuccess) {
                        final userId = userState.userId;
                        // ignore: unnecessary_null_comparison
                        if (userId != null) {
                          final customerFuture =
                              CustomerService().getCustomerByUserId(userId);
                          customerFuture.then((customer) {
                            if (customer != null) {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditCustomerPage(customer: customer),
                                    ),
                                  )
                                  .then((value) {
                                if (value == true) {
                                  _loadCustomers();
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Customer data not found')),
                              );
                            }
                          });
                        }
                      }
                    },
                  ),
                  // _buildProfileMenuItem(
                  //   icon: Icons.bookmark_border,
                  //   title: 'Bookmark',
                  //   iconColor: Colors.orange.shade700,
                  //   onTap: () {
                  //     print('Bookmark tapped (design only)');
                  //   },
                  // ),
                  // _buildProfileMenuItem(
                  //   icon: Icons.lock_outline,
                  //   title: 'Change Password',
                  //   iconColor: Colors.red.shade600,
                  //   onTap: () {
                  //     print('Change Password tapped (design only)');
                  //   },
                  // ),
                  // _buildProfileMenuItem(
                  //   icon: Icons.privacy_tip_outlined,
                  //   title: 'Privacy Policy',
                  //   iconColor: Colors.green.shade700,
                  //   onTap: () {
                  //     print('Privacy Policy tapped (design only)');
                  //   },
                  // ),
                  _buildProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    iconColor: Colors.grey.shade800,
                    onTap: () async {
                      final userBloc = BlocProvider.of<UserBloc>(context);
                      final authRepository = AuthRepository();
                      try {
                        await authRepository.signOut(userBloc);
                        if (mounted) {
                          // Navigate to login page without popping context to avoid black screen
                          context.go('/login');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logout failed: \$e')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 30.0), // Spasi di bawah
                ],
              ),
            ),
          ),
        ));
  }
}
