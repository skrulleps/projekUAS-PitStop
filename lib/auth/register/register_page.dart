import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitstop/home/bloc/user_bloc.dart';
import 'register_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../auth_repository.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailValid = false;

  // Validasi password
  bool get hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get hasNumber => _passwordController.text.contains(RegExp(r'\d'));
  bool get hasNoSpace => !_passwordController.text.contains(' ');
  bool get isPasswordValid =>
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasNoSpace &&
      _passwordController.text.length >= 8;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _emailController.addListener(() {
      setState(() {
        _emailValid = _emailController.text.contains('@');
      });
    });
  }

  Widget _buildRequirement(String text, bool fulfilled) {
    return Row(
      children: [
        Icon(
          fulfilled ? Icons.check_circle : Icons.cancel,
          color: fulfilled ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);
    return BlocProvider(
      create: (_) => RegisterBloc(authRepository: AuthRepository()),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 0),
                Image.asset('assets/images/logobg.png',
                    height: 150), // Logo aplikasi
                const SizedBox(height: 0),
                const Text('Sign Up',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 0),
                const Text('Enter detail to sign up your account',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),

                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _emailValid || _emailController.text.isEmpty
                        ? null
                        : 'Invalid email, email must contain @',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => context
                      .read<RegisterBloc>()
                      .add(RegisterEmailChanged(value)),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) => context
                      .read<RegisterBloc>()
                      .add(RegisterPasswordChanged(value)),
                ),
                const SizedBox(height: 12),

                // Password validation list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequirement(
                        "At least one uppercase letter", hasUppercase),
                    _buildRequirement(
                        "At least one lowercase letter", hasLowercase),
                    _buildRequirement("At least one number", hasNumber),
                    _buildRequirement("No spaces allowed", hasNoSpace),
                    _buildRequirement("Minimum 8 characters",
                        _passwordController.text.length >= 8),
                  ],
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocConsumer<RegisterBloc, RegisterState>(
                    listener: (context, state) {
                      if (state.isFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage)),
                        );
                      } else if (state.isSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Register berhasil!')),
                        );
                        context.go('/login');
                      }
                    },
                    builder: (context, state) {
                      if (state.isSubmitting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: isPasswordValid && _emailValid
                            ? () {
                                context
                                    .read<RegisterBloc>()
                                    .add(RegisterSubmitted(
                                      username: _usernameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ));
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          disabledBackgroundColor: Colors.amber[100],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Sign Up',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text("Guest User",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account ? "),
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
