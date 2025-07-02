import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Hanya GoRouter yang dipertahankan

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data dummy untuk kartu barber shop (tetap ada karena digunakan di bagian bawah)
  final List<Map<String, String>> barberShops = [
    {
      'image': 'assets/images/tempat.jpg', // Pastikan path gambar ini benar
      'rating': '4.5',
      'status': 'Buka Sekarang', // Diubah
      'time': '10 pagi - 10 malam', // Diubah
      'name': 'GENTLEMEN CLUB',
      'distance': '0.5 km',
    },
    {
      'image': 'assets/images/tempat2.jpg', // Pastikan path gambar ini benar
      'rating': '4.5',
      'status': 'Buka Sekarang', // Diubah
      'time': '10 pagi - 10 malam', // Diubah
      'name': 'GENTLEMEN CLUB',
      'distance': '0.5 km',
    },
    // Tambahkan lebih banyak data jika diperlukan
  ];

  @override
  void initState() {
    super.initState();
  }

  // Widget untuk membangun bilah pencarian dengan dropdown kota
  Widget _buildSearchBarWithDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2233), // Latar belakang gelap untuk search bar
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: null,
                hint: const Text(
                  'Pilih Kota Anda', // Diubah ke Bahasa Indonesia
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white54,
                ),
                dropdownColor: const Color(0xFF1A2233),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (String? newValue) {
                  // Logika onChanged akan kosong atau pindah ke tempat lain
                },
                items:
                    <String>[
                      'Jakarta', // Diubah ke nama kota Indonesia jika relevan
                      'Bandung',
                      'Surabaya',
                      'Medan',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat item menu grid
  Widget _buildMenuItem(IconData icon, String label, String routePath) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Navigasi menggunakan GoRouter
          context.push(routePath);
        },
        child: Container(
          height: 100, // Tinggi tetap untuk setiap item menu
          margin: const EdgeInsets.symmetric(
            horizontal: 5.0,
          ), // Jarak antar item
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2233), // Warna latar belakang item menu
            borderRadius: BorderRadius.circular(12.0), // Sudut membulat
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: const Color(0xFFFFD700),
                size: 35,
              ), // Ikon, warna emas
              const SizedBox(height: 8.0),
              Text(
                label, // Label teks
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun grid menu 2x2
  Widget _buildGridMenu() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuItem(
              Icons.add_box_outlined,
              'Tambah Layanan', // Diubah ke Bahasa Indonesia
              '/add_booking',
            ),
            _buildMenuItem(
              Icons.list_alt,
              'Daftar Layanan',
              '/service_list',
            ), // Diubah ke Bahasa Indonesia
          ],
        ),
        const SizedBox(height: 10), // Spasi antar baris
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuItem(
              Icons.person_outline,
              'Profil',
              '/profile',
            ), // Diubah ke Bahasa Indonesia
            _buildMenuItem(
              Icons.history,
              'Riwayat Saya',
              '/my_bookings',
            ), // Diubah ke Bahasa Indonesia
          ],
        ),
      ],
    );
  }

  // Widget untuk menampilkan daftar barber shop horizontal
  Widget _buildBarberShopsList() {
    return SizedBox(
      height: 270, // Tinggi tetap untuk ListView horizontal
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: barberShops.length,
        itemBuilder: (context, index) {
          final shop = barberShops[index];
          return _buildBarberShopCard(shop);
        },
      ),
    );
  }

  // Widget untuk membangun setiap kartu barber shop
  Widget _buildBarberShopCard(Map<String, String> shop) {
    return Container(
      width: 180, // Lebar kartu
      margin: const EdgeInsets.only(right: 15), // Jarak antar kartu
      decoration: BoxDecoration(
        color: const Color(0xFF1A2233), // Latar belakang gelap untuk kartu
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  shop['image']!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        shop['rating']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Menggunakan interpolasi string yang sudah diubah di data dummy
                  '${shop['status']!} • ${shop['time']!}',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  shop['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  shop['distance']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 10),
                _buildBookNowButton(
                  text: 'Pesan Sekarang',
                  width: double.infinity,
                ), // Diubah ke Bahasa Indonesia
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun kartu promosi (best barbers)
  Widget _buildPromotionalCard() {
    return Container(
      width: double.infinity,
      height: 270, // Tinggi tetap untuk kartu promosi
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/barber.jpg',
          ), // Pastikan path gambar ini benar
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Overlay gelap untuk keterbacaan teks
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.7), // Lebih gelap di kiri
                  Colors.transparent, // Transparan di kanan
                ],
                stops: const [0.0, 0.7], // Kontrol sebaran gradien
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(), // Dorong teks dan tombol ke bawah
                const Text(
                  'RAMBUT ANDA', // Diubah ke Bahasa Indonesia
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'LAYAK MENDAPATKAN YANG TERBAIK.', // Diubah ke Bahasa Indonesia
                  style: TextStyle(
                    color: Color(0xFFFFD700), // Warna emas
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nikmati & bersantai di lingkungan\nBarber shop yang mewah', // Diubah ke Bahasa Indonesia
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 15),
                _buildBookNowButton(
                  text: 'Pesan Sekarang', // Diubah ke Bahasa Indonesia
                  width: 150, // Sesuaikan lebar tombol jika perlu
                ),
                const SizedBox(height: 10), // Padding di bawah tombol
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun tombol "Book Now"
  Widget _buildBookNowButton({required String text, required double width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Warna emas
        borderRadius: BorderRadius.circular(8),
      ),
      child: MaterialButton(
        padding: EdgeInsets.zero, // Hapus padding default MaterialButton
        onPressed: () {
          print('$text ditekan'); // Diubah ke Bahasa Indonesia
          // Tambahkan navigasi atau logika pemesanan di sini
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Metode build utama untuk tampilan HomeScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E), // Latar belakang biru gelap
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // Jika tidak bisa pop, mungkin ini halaman pertama, lakukan sesuatu yang lain
              // contoh: context.go('/login');
            }
          },
        ),
        title: const Text(
          'Selamat Datang!', // Diubah ke Bahasa Indonesia
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Tangani aksi menu
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Teks "Sharpen and stylish..."
            const Text(
              'Tajam dan Stylish! Pesan janji temu barber Anda sekarang.', // Diubah ke Bahasa Indonesia
              style: TextStyle(color: Colors.amber, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Search Bar
            _buildSearchBarWithDropdown(),

            const SizedBox(height: 25), // Spasi sebelum grid menu
            // Grid Menu 2x2
            _buildGridMenu(),

            const SizedBox(height: 30), // Spasi setelah grid menu
            const Divider(color: Colors.grey), // Garis pemisah
            // Bagian "Barber Tersedia di Lokasi Anda"
            const SizedBox(height: 10), // Spasi setelah divider
            const Text(
              'Barber Tersedia di Lokasi Anda', // Diubah ke Bahasa Indonesia
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildBarberShopsList(), // Memanggil list barber shop

            const SizedBox(height: 30),

            // Bagian "Barber Terbaik Minggu Ini"
            const Text(
              'Barber Terbaik Minggu Ini', // Diubah ke Bahasa Indonesia
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildPromotionalCard(), // Memanggil kartu promosi

            const SizedBox(height: 20), // Spasi terakhir
          ],
        ),
      ),
    );
  }
}
