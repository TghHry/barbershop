import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Latar belakang hitam solid untuk tepi
      body: Stack(
        children: [
          // Gambar Latar Belakang
          Positioned.fill(
            child: Image.asset(
              'assets/images/cukur.jpg', // Path ke gambar Anda
              fit: BoxFit.cover, // Menutupi seluruh area
            ),
          ),

          // Overlay Gelap untuk membuat teks/tombol mudah dibaca
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.6,
              ), // Sesuaikan opacity sesuai kebutuhan
            ),
          ),

          // Konten: Tombol dan Ikon Sosial
          Column(
            children: [
              // Spacer untuk mendorong konten ke bawah (sesuaikan sesuai kebutuhan)
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30.0,
                ),
                child: Column(
                  children: <Widget>[
                    // Tombol MASUK (SIGN IN)
                    _buildSignInButton(),
                    const SizedBox(height: 16),
                    // Tombol DAFTAR (SIGN UP)
                    _buildSignUpButton(),
                    const SizedBox(height: 20),
                    // Lupa Kata Sandi?
                    TextButton(
                      onPressed: () {
                        // Tangani ketukan lupa kata sandi
                        print('Lupa Kata Sandi?');
                      },
                      child: Text(
                        'Lupa Kata Sandi ?', // Diubah ke Bahasa Indonesia
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Ikon Media Sosial
                    _buildSocialMediaIcons(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      width: double.infinity,
      height: 55, // Tinggi tetap untuk tombol
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Warna Kuning/Emas
        borderRadius: BorderRadius.circular(12),
      ),
      child: MaterialButton(
        onPressed: () {
          context.go('/login'); // Tangani Masuk (Sign In)
          print('Tombol MASUK Ditekan'); // Diubah ke Bahasa Indonesia
        },
        child: const Text(
          'MASUK', // Diubah ke Bahasa Indonesia
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 55, // Tinggi tetap untuk tombol
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700), // Border Kuning/Emas
          width: 2,
        ),
      ),
      child: MaterialButton(
        onPressed: () {
          context.go('/register');
          print('Tombol DAFTAR Ditekan'); // Diubah ke Bahasa Indonesia
        },
        child: const Text(
          'DAFTAR', // Diubah ke Bahasa Indonesia
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(FontAwesomeIcons.facebookF),
        const SizedBox(width: 20),
        _buildSocialIcon(FontAwesomeIcons.google),
        const SizedBox(width: 20),
        _buildSocialIcon(
          FontAwesomeIcons.xTwitter,
        ), // Menggunakan FontAwesomeIcons.xTwitter
      ],
    );
  }

  Widget _buildSocialIcon(IconData iconData) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(
            0.5,
          ), // Border lebih terang untuk ikon sosial
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(iconData, color: Colors.white.withOpacity(0.7), size: 28),
        onPressed: () {
          // Tangani ketukan ikon media sosial
          print('Ikon sosial ditekan: $iconData'); // Diubah ke Bahasa Indonesia
        },
      ),
    );
  }
}
