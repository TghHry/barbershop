import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import flutter_secure_storage
import 'dart:async'; // For TimeoutException
import 'dart:io'; // For SocketException

// Correct imports for your services and models
import 'package:barbershop2/presentations/admin/auth/login/services/login_service.dart'; // Assuming your AuthService is here
import 'package:barbershop2/presentations/admin/auth/login/models/login_model.dart'; // Assuming your LoginResponse model is here

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool isLoading = false;

  // Create an instance of FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Optional: Add a debug print to check if a token already exists on screen load
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    debugPrint('LoginScreen: Checking for existing token in secure storage...');
    final String? existingToken = await _secureStorage.read(key: 'auth_token');
    if (existingToken != null) {
      debugPrint(
        'LoginScreen: Found existing token (length: ${existingToken.length}) in secure storage.',
      );
      // In a real app, you might validate this token or automatically navigate
      // context.go('/home'); // Example: Auto-login if valid token exists
    } else {
      debugPrint('LoginScreen: No existing token found in secure storage.');
    }
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('LoginScreen: Form validation failed.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    debugPrint(
      'LoginScreen: Attempting login for email: ${_emailController.text}',
    );

    try {
      final LoginResponse res = await _authService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint('LoginScreen: API Login Response Message: ${res.message}');
      debugPrint('LoginScreen: API Login Response Token: ${res.data.token}');
      debugPrint(
        'LoginScreen: API Login Response User Name: ${res.data.user.name}',
      );

      final token = res.data.token;
      final user = res.data.user;

      // --- Store token securely using FlutterSecureStorage ---
      debugPrint('LoginScreen: Attempting to save token to secure storage...');
      await _secureStorage.write(key: 'auth_token', value: token);
      debugPrint(
        'LoginScreen: Token successfully saved to secure storage. Token length: ${token.length}',
      );

      // --- Store other user info in SharedPreferences (non-sensitive) ---
      debugPrint(
        'LoginScreen: Attempting to save user details to SharedPreferences...',
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.name);
      await prefs.setInt('user_id', user.id);
      await prefs.setString('user_email', user.email);
      debugPrint(
        'LoginScreen: User details successfully saved to SharedPreferences.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login berhasil!"),
            backgroundColor: Colors.green,
          ),
        );

        context.go(
          '/home',
        ); // IMPORTANT: Replace '/home' with your actual home route path
        debugPrint('LoginScreen: Navigating to /home after successful login.');
      }
    } catch (e) {
      debugPrint('LoginScreen: Error during login process: $e');
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (e is SocketException) {
        errorMessage =
            'Tidak ada koneksi internet. Mohon periksa koneksi Anda.';
      } else if (e is TimeoutException) {
        errorMessage = 'Permintaan login ke server habis waktu. Coba lagi.';
      } else if (errorMessage.toLowerCase().contains('invalid credentials')) {
        errorMessage = 'Email atau password salah. Mohon periksa kembali.';
      } else if (errorMessage.toLowerCase().contains('email belum terdaftar')) {
        errorMessage = 'Email belum terdaftar. Silakan daftar akun baru.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action:
                errorMessage.contains('daftar akun baru') ||
                        errorMessage.contains('Email belum terdaftar')
                    ? SnackBarAction(
                      label: 'Daftar',
                      onPressed: () {
                        context.go('/register');
                      },
                    )
                    : null,
          ),
        );
        debugPrint('LoginScreen: Displayed error message: "$errorMessage"');
      }
    } finally {
      setState(() => isLoading = false);
      debugPrint('LoginScreen: Loading state set to false.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 150),
                  const Icon(
                    Icons.switch_access_shortcut_sharp,
                    size: 80,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Scukur.in',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // const Text(
                  //   'BARBERSHOP',
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  // ),
                  const SizedBox(height: 10),
                  const Text(
                    'Log In',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter your email address",
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: "Enter your password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 370,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account? "),
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
