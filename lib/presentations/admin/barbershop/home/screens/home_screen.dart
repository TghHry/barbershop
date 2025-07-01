import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart'; // Untuk navigasi (misalnya, logout)
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk logout yang aman
import 'package:carousel_slider/carousel_slider.dart'; // Untuk carousel
import 'package:barbershop2/presentations/admin/barbershop/home/screens/widget/promo_card.dart'; // Impor PromoCard Anda
// Pastikan path untuk ServiceService dan ServiceItem models sudah benar di ServicesListScreen
// Tidak perlu diimpor langsung di HomeScreen kecuali HomeScreen akan memanggilnya secara langsung.
// import 'package:barbershop2/presentations/admin/barbershop/list_service/list_service_service/list_service.dart';
// import 'package:barbershop2/presentations/admin/barbershop/list_service/list_service_models/list_service_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // <<< KOREKSI: Ubah _HomeScreen menjadi _HomeScreenState
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  // <<< PASTIKAN DEKLARASI INI ADA DAN BENAR >>>
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final List<Map<String, String>> promoData = [
    {
      'title': 'Daily Promo',
      'discountText': '50%',
      'description': 'Dapatkan diskon besar untuk kunjungan Anda berikutnya!',
      // 'imagePath': 'assets/images/cukur.jpg',
    },
    {
      'title': 'Weekend Special',
      'discountText': '20%',
      'description': 'Diskon khusus untuk layanan di akhir pekan ini!',
      // 'imagePath': 'assets/images/cukur2.jpg',
    },
    {
      'title': 'New Member',
      'discountText': '30%',
      'description': 'Diskon untuk member baru yang daftar hari ini!',
      // 'imagePath': 'assets/images/cukur3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
      debugPrint('HomeScreen: Nama pengguna dimuat: $_userName');
    });
  }

  // <<< PASTIKAN DEFINISI METODE INI ADA DAN BENAR >>>
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Bersihkan semua data SharedPreferences
    await _secureStorage.delete(
      key: 'auth_token',
    ); // Hapus token dari secure storage
    debugPrint('HomeScreen: Data pengguna dan token dibersihkan.');

    if (mounted) {
      context.go(
        '/login',
      ); // Kembali ke layar login dan bersihkan tumpukan navigasi
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Pastikan ini SingleChildScrollView
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Bagian Selamat Datang
            Center(
              child: Text(
                'Welcome,',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Center(
              child: Text(
                ' ${_userName ?? 'Guest'}!', // Tampilkan nama pengguna
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 15),
            // <<< KOREKSI: Hapus blok SizedBox/Container/Row yang duplikat untuk "My Bookings"
            // Gantikan dengan tombol _buildActionButton di bagian Quick Actions
            // --- Carousel Promo Card ---
            CarouselSlider.builder(
              itemCount: promoData.length,
              itemBuilder: (
                BuildContext context,
                int itemIndex,
                int pageViewIndex,
              ) {
                final promo = promoData[itemIndex];
                return PromoCard(
                  title: promo['title']!,
                  discountText: promo['discountText']!,
                  description: promo['description']!,
                  // imagePath: promo['imagePath']!,
                );
              },
              options: CarouselOptions(
                height: 200.0,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                aspectRatio: 16 / 9,
                viewportFraction: 0.9,
                scrollDirection: Axis.horizontal,
              ),
            ),
            const SizedBox(height: 30), // Spasi setelah carousel
            // --- Bagian Quick Actions (di bawah carousel) ---
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.add,
                    label: 'Tambahkan Layanan',
                    onTap: () {
                      if (mounted) {
                        context.push(
                          '/add_booking',
                        ); // Menavigasi ke riwayat booking
                        debugPrint(
                          'HomeScreen: "My Bookings" ditekan. Menavigasi ke /my_bookings.',
                        );
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  _buildActionButton(
                    icon: Icons.cut,
                    label: 'Layanan Kami',
                    onTap: () {
                      if (mounted) {
                        context.push(
                          '/service_list',
                        ); // Menavigasi ke daftar layanan
                        debugPrint(
                          'HomeScreen: "Our Services" ditekan. Menavigasi ke /services_list.',
                        );
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  _buildActionButton(
                    icon: Icons.history,
                    label: 'Historyku',
                    onTap: () {
                      if (mounted) {
                        context.push(
                          '/my_bookings',
                        ); // Menavigasi ke riwayat booking
                        debugPrint(
                          'HomeScreen: "My Bookings" ditekan. Menavigasi ke /my_bookings.',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Divider(),
            // --- Bagian Upcoming Bookings (Card) ---
            const Text(
              'Update Booking ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // Menggunakan Card "No upcoming bookings" yang sudah kita buat
            Center(
              child: Card(
                color: Colors.white,
                // <<< KOREKSI: Gunakan Card langsung
                margin: const EdgeInsets.all(
                  0,
                ), // Margin 0 karena sudah ada padding di parent
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today, // Ikon kalender
                        size: 70, // Ukuran lebih besar
                        color: Colors.grey[400], // Warna abu-abu lembut
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tidak ada Update Booking.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'Tekan "'),
                            TextSpan(
                              text: 'Booking Sekarang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(text: '" untuk menjadwalkan kunjunganmu!'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Up ooooolits 8 bomlter', // Jika teks ini tidak diperlukan, hapus saja
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 320,
                height: 48,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Log Out", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
