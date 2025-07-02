import 'package:flutter/material.dart';
import 'package:barbershop2/presentations/admin/auth/register/services/register_service.dart';
import 'package:barbershop2/presentations/admin/auth/register/models/register_model.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui'; // Diperlukan untuk ImageFilter

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void register() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('RegisterScreen: Validasi formulir gagal.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });

    debugPrint(
      'RegisterScreen: Mencoba registrasi untuk email: ${_emailController.text}',
    );

    try {
      final RegistrationResponse res = await _authService.registerUser(
        email: _emailController.text.trim(),
        name: _usernameController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      debugPrint('Register Response: ${res.message}');
      debugPrint('Register Response Token: ${res.data.token}');
      debugPrint(
        'Register Response User: ${res.data.user.name}, ${res.data.user.email}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil!"),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
        debugPrint(
          'RegisterScreen: Navigasi ke /login setelah registrasi berhasil.',
        );
      }
    } catch (e) {
      debugPrint('Register Error: $e');
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (errorMessage.contains('email has already been taken')) {
        errorMessage = 'Email sudah terdaftar. Gunakan email lain.';
      } else if (errorMessage.contains(
        'password confirmation does not match',
      )) {
        errorMessage = 'Konfirmasi password tidak cocok.';
      } else if (errorMessage.contains('No Internet connection')) {
        errorMessage =
            'Tidak ada koneksi internet. Mohon periksa koneksi Anda.';
      } else if (errorMessage.contains('Request timed out')) {
        errorMessage = 'Permintaan ke server habis waktu. Coba lagi.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        debugPrint('RegisterScreen: Menampilkan pesan error: "$errorMessage"');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
      debugPrint('RegisterScreen: Status loading diatur ke false.');
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
                  const SizedBox(height: 90),
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
                  const SizedBox(height: 20),

                  const Text(
                    'Daftar Akun',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Input Nama Lengkap
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _usernameController,
                    style: const TextStyle(
                      color: Colors.grey,
                    ), // Teks input berwarna abu-abu
                    decoration: InputDecoration(
                      // Menggunakan InputDecoration tanpa const karena fillcolor
                      hintText: "Masukkan nama lengkap Anda",
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ), // Hint text lebih gelap
                      labelText: 'Nama Lengkap',
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
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? "Nama pengguna wajib diisi"
                                : null,
                  ),
                  const SizedBox(height: 20),
                  // Input Email
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    style: TextStyle(
                      color: Colors.grey[200],
                    ), // Teks input berwarna abu-abu terang
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Email wajib diisi";
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(val)) {
                        return "Email tidak valid";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      // Menggunakan InputDecoration tanpa const
                      hintText: "Masukkan alamat email Anda",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      labelText: 'Alamat Email',
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      color: Colors.grey[200],
                    ), // Teks input berwarna abu-abu terang
                    validator:
                        (val) =>
                            val == null || val.length < 6
                                ? "Password minimal 6 karakter"
                                : null,
                    decoration: InputDecoration(
                      // Menggunakan InputDecoration tanpa const
                      labelText: 'Password',
                      hintText: "Masukkan password Anda",
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
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey, // Warna ikon visibility
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Input Konfirmasi Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(
                      color: Colors.grey[200],
                    ), // Teks input berwarna abu-abu terang
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Konfirmasi password wajib diisi";
                      }
                      if (val != _passwordController.text) {
                        return "Password tidak cocok";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      // Menggunakan InputDecoration tanpa const
                      labelText: 'Konfirmasi Password',
                      hintText: "Masukkan ulang password Anda",
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
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey, // Warna ikon visibility
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Tombol Daftar
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
                      onPressed: isLoading ? null : register,
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                              : const Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tautan Sudah Punya Akun?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun?",
                        style: TextStyle(fontSize: 18, color: Colors.amber),
                      ),
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            context.push('/login');
                          }
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(color: Colors.amber),
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
