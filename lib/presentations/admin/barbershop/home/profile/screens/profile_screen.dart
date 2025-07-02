import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Untuk navigasi GoRouter
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan data pengguna
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk menyimpan token dengan aman
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName; // Variabel untuk menyimpan nama pengguna
  String? _userEmail; // *** BARU: Variabel untuk menyimpan email pengguna ***
  int? _userId; // *** BARU: Variabel untuk menyimpan ID pengguna ***

  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage(); // Objek untuk secure storage

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Panggil metode untuk memuat data pengguna saat inisialisasi
  }

  // Metode untuk memuat data pengguna dari SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString(
        'user_email',
      ); // *** DIMUAT: Email pengguna ***
      _userId = prefs.getInt('user_id'); // *** DIMUAT: ID pengguna ***

      debugPrint('ProfileScreen: Nama pengguna dimuat: $_userName');
      debugPrint('ProfileScreen: Email pengguna dimuat: $_userEmail');
      debugPrint('ProfileScreen: ID pengguna dimuat: $_userId');
    });
  }

  // Metode untuk menangani logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Bersihkan semua data SharedPreferences
    await _secureStorage.delete(
      key: 'auth_token',
    ); // Hapus token dari secure storage
    debugPrint('ProfileScreen: Data pengguna dan token dibersihkan.');

    if (mounted) {
      // Pastikan widget masih ada di tree sebelum navigasi
      context.go(
        '/login',
      ); // Kembali ke layar login dan bersihkan tumpukan navigasi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2233),
      appBar: AppBar(
        title: const Text(
          'Profil Saya', // Diubah ke Bahasa Indonesia
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A2233),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), // Ikon panah kembali
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              debugPrint(
                'ProfileScreen: Tidak ada halaman sebelumnya untuk di-pop.', // Diubah
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Tangani pencarian
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              // Tangani bookmark
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        // Stack diubah menjadi SingleChildScrollView langsung
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            _buildProfilePicture(),
            const SizedBox(height: 20),
            Text(
              // Tampilkan nama pengguna yang dimuat, atau 'Tamu' jika null
              _userName ?? 'Tamu', // Diubah ke Bahasa Indonesia
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w400,
                fontFamily: 'DancingScript', // Pastikan font ini tersedia
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // Tampilkan email pengguna yang dimuat, atau placeholder
              _userEmail ??
                  'email@example.com', // *** DIGANTI dengan _userEmail ***
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              // Tampilkan ID pengguna, atau placeholder
              _userId != null
                  ? 'ID Pengguna: $_userId'
                  : 'ID Pengguna: N/A', // *** DIGANTI dengan _userId ***
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildAccountInfoSection(), // Nama metode diubah
            const SizedBox(height: 30),
            // Tombol "Log Out" sekarang memanggil _logout()
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Metode Pembantu (Helper Methods) ---

  Widget _buildProfilePicture() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/barber.jpg', // Pastikan path gambar ini benar
          width: 140,
          height: 140,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Nama metode diubah dari _buildToucseRappentSection
  Widget _buildAccountInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2233),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun', // Diubah ke Bahasa Indonesia
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          // Menggunakan _buildAccountListItem untuk item-item yang bisa diketuk
          _buildAccountListItem('Riwayat Pemesanan', () {
            context.push(
              '/my_bookings',
            ); // Contoh navigasi ke riwayat pemesanan
          }),
          _buildAccountListItem('Pengaturan Aplikasi', () {
            // Aksi untuk pengaturan aplikasi
            debugPrint('Pengaturan Aplikasi Ditekan');
          }),
          _buildAccountListItem('Bantuan & Dukungan', () {
            // Aksi untuk bantuan dan dukungan
            debugPrint('Bantuan & Dukungan Ditekan');
          }),
          _buildAccountListItem('Tentang Aplikasi', () {
            // Diubah dari 'Informasi'
            // Aksi untuk informasi tentang aplikasi
            debugPrint('Informasi Aplikasi Ditekan');
          }),
        ],
      ),
    );
  }

  // Metode pembantu baru untuk item daftar yang dapat diklik
  Widget _buildAccountListItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Metode _buildListItem sebelumnya dihapus karena diganti oleh _buildAccountListItem
  // Widget _buildListItem(String title, String amount) { ... }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
      ),
      child: MaterialButton(
        onPressed: _logout, // Memanggil metode _logout() saat tombol ditekan
        child: const Text(
          'Keluar', // Diubah ke Bahasa Indonesia
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
