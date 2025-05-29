// import 'dart:typed_data';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:pitstop/features/auth/auth_repository.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({Key? key}) : super(key: key);

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   Uint8List? _imageBytes;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image == null) return;

//       final bytes = await image.readAsBytes();

//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User not logged in')),
//           );
//         }
//         return;
//       }

//       // Get user id from users table
//       final userResponse =
//           await supabase.from('users').select('id').eq('id', user.id).single();

//       if (userResponse == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User not found in users table')),
//           );
//         }
//         return;
//       }

//       // Get users_id from profiles table
//       final profileResponse = await supabase
//           .from('profiles')
//           .select('users_id')
//           .eq('users_id', user.id)
//           .single();

//       if (profileResponse == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile not found')),
//           );
//         }
//         return;
//       }

//       // Check if users.id == profiles.users_id
//       if (userResponse['id'] != profileResponse['users_id']) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User ID mismatch')),
//           );
//         }
//         return;
//       }

//       // Convert bytes to base64 string for bytea string storage
//       final String base64String = base64Encode(bytes);

//       final response = await supabase
//           .from('profiles')
//           .update({'photo': base64String})
//           .eq('users_id', user.id)
//           .select();

//       if (response == null || (response is List && response.isEmpty)) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to update photo')),
//           );
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _imageBytes = bytes;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile photo updated')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error picking image: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color amberColor = Colors.amber.shade600;
//     final Color iconBackground = Colors.amber.shade100;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage:
//                       _imageBytes != null ? MemoryImage(_imageBytes!) : null,
//                   child: _imageBytes == null
//                       ? const Icon(Icons.person, size: 50)
//                       : null,
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: amberColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.camera_alt, color: Colors.white),
//                     onPressed: _pickImage,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'Maria Sant',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 24),
//             Expanded(
//               child: ListView(
//                 children: [
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.person_outline,
//                     label: 'Edit Profile',
//                     onTap: () {
//                       context.push('/edit-profile');
//                     },
//                     iconBackground: iconBackground,
//                     iconColor: amberColor,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.bookmark_border,
//                     label: 'Bookmark',
//                     onTap: () {
//                       // TODO: Navigate to bookmark
//                     },
//                     iconBackground: iconBackground,
//                     iconColor: amberColor,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.lock_outline,
//                     label: 'Change Password',
//                     onTap: () {
//                       // TODO: Navigate to change password
//                     },
//                     iconBackground: iconBackground,
//                     iconColor: amberColor,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.privacy_tip_outlined,
//                     label: 'Privacy Policy',
//                     onTap: () {
//                       // TODO: Show privacy policy
//                     },
//                     iconBackground: iconBackground,
//                     iconColor: amberColor,
//                   ),
//                   _buildMenuItem(
//                     context,
//                     icon: Icons.logout,
//                     label: 'Sign Out',
//                     onTap: () async {
//                       final authRepository = AuthRepository();
//                       await authRepository.signOut();
//                       if (context.mounted) {
//                         context.go('/login');
//                       }
//                     },
//                     iconBackground: iconBackground,
//                     iconColor: amberColor,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(BuildContext context,
//       {required IconData icon,
//       required String label,
//       required VoidCallback onTap,
//       required Color iconBackground,
//       required Color iconColor}) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: Container(
//           decoration: BoxDecoration(
//             color: iconBackground,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding: const EdgeInsets.all(8),
//           child: Icon(icon, color: iconColor),
//         ),
//         title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//         onTap: onTap,
//       ),
//     );
//   }
// }
