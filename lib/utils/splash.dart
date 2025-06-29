import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Pastikan Anda sudah menambahkan go_router sebagai dependensi

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // <<< HILANGKAN FUTURE.DELAYED DI SINI >>>
    debugPrint('SplashScreen: Init, menunggu tombol diklik untuk navigasi.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang abu-abu muda
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Grafik Barbershop (Gunting dan Ombak/Sisir)
            const Icon(
              Icons.content_cut, // Ikon gunting
              size: 80.0,
              color: Colors.black87,
            ),
            const SizedBox(height: 8.0),
            const Icon(
              Icons.waves, // Merepresentasikan sisir atau rambut yang digayakan
              size: 40.0,
              color: Colors.black54,
            ),
            const SizedBox(height: 32.0), // Spasi
            // Nama Aplikasi
            const Text(
              'BARBERSHOP',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 2.0, // Spasi antar huruf
              ),
            ),
            const SizedBox(height: 8.0), // Spasi
            // Teks "Made with Flutter" (Opsional)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Made with Flutter',
                  style: TextStyle(fontSize: 12.0, color: Colors.black54),
                ),
                SizedBox(width: 4.0),
                Icon(
                  Icons.favorite, // Ikon hati
                  size: 12.0,
                  color: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 48.0), // Spasi sebelum tombol
            // <<< TAMBAH TOMBOL UNTUK NAVIGASI >>>
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  debugPrint(
                    'SplashScreen: Tombol diklik. Menavigasi ke /login.',
                  );
                  context.go(
                    '/login',
                  ); // Ganti '/login' dengan rute halaman login Anda yang sebenarnya
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87, // Warna tombol
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ), // Ikon panah ke depan
            ),
            // <<< AKHIR TOMBOL >>>
          ],
        ),
      ),
    );
  }
}
