import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui'; // Diperlukan untuk ImageFilter

// Correct imports for your services and models
import 'package:barbershop2/presentations/admin/auth/login/services/login_service.dart';
import 'package:barbershop2/presentations/admin/auth/login/models/login_model.dart';

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

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    debugPrint('LoginScreen: Checking for existing token in secure storage...');
    final String? existingToken = await _secureStorage.read(key: 'auth_token');
    if (existingToken != null) {
      debugPrint(
        'LoginScreen: Found existing token (length: ${existingToken.length}) in secure storage.',
      );
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

      debugPrint('LoginScreen: Attempting to save token to secure storage...');
      await _secureStorage.write(key: 'auth_token', value: token);
      debugPrint(
        'LoginScreen: Token successfully saved to secure storage. Token length: ${token.length}',
      );

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

        context.go('/home');
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
      backgroundColor: const Color(0xFF0A0F1E),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Stack(
                    // *** DIHAPUS 'const' di sini ***
                    alignment: Alignment.center,
                    children: [
                      // Efek glow yang diblur
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.5, // Sesuaikan opacity glow
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 10,
                              sigmaY: 10,
                            ), // Sesuaikan intensitas blur
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                // *** DITAMBAHKAN 'const' di sini ***
                                Colors
                                    .amberAccent, // Warna glow (tanpa opacity di sini, karena Opacity di luar)
                                BlendMode.srcATop,
                              ),
                              child: Image.asset(
                                'assets/images/logo.png', // Path aset logo Anda
                                fit: BoxFit.contain,
                                // *** DIHAPUS: properti 'color' di sini, ColorFiltered sudah menanganinya ***
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Logo utama
                      Image.asset(
                        'assets/images/logo.png', // Path aset logo Anda
                        height: 120, // Sesuaikan ukuran logo
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.grey[200],
                    ), // Teks input berwarna abu-abu terang
                    decoration: InputDecoration(
                      // Menggunakan InputDecoration tanpa const karena fillcolor
                      hintText:
                          "Masukkan alamat email Anda", // Diubah ke Bahasa Indonesia
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ), // Hint text lebih gelap
                      labelText: 'Alamat Email', // Diubah ke Bahasa Indonesia
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ), // Label berwarna abu-abu
                      filled: true, // Mengaktifkan pengisian warna background
                      fillColor: Colors.white.withOpacity(
                        0.05,
                      ), // Background textfield sedikit transparan
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                        ), // Border abu-abu saat tidak fokus
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ), // Border putih saat fokus
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                        ), // Border merah untuk error
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.red,
                        ), // Border merah saat error dan fokus
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    style: TextStyle(
                      color: Colors.grey[200],
                    ), // Teks input berwarna abu-abu terang
                    decoration: InputDecoration(
                      // Menggunakan InputDecoration tanpa const
                      labelText: 'Password', // Diubah ke Bahasa Indonesia
                      hintText:
                          "Masukkan password Anda", // Diubah ke Bahasa Indonesia
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                          color: Colors.grey, // Warna ikon visibility
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
                  Container(
                    width: 370,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x80FFD700),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      padding: EdgeInsets.zero,
                      onPressed: isLoading ? null : login,
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                              : const Text(
                                "Login", // Diubah ke Bahasa Indonesia
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun?", // Diubah ke Bahasa Indonesia
                        style: TextStyle(color: Colors.amber),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: const Text(
                          'Daftar', // Diubah ke Bahasa Indonesia
                          style: TextStyle(
                            color: Colors.amber,
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
