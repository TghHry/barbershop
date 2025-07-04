import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:go_router/go_router.dart'; // Untuk navigasi (misalnya, kembali)
import 'package:intl/intl.dart'; // Untuk pemformatan tanggal

import 'package:barbershop2/presentations/admin/barbershop/home/history/history_service/history_service.dart'; // Sesuaikan path jika diperlukan
import 'package:barbershop2/presentations/admin/barbershop/home/history/history_models/history_model.dart'; // Sesuaikan path jika diperlukan

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingHistoryService _bookingHistoryService = BookingHistoryService();
  late Future<BookingHistoryResponse> _bookingHistoryFuture;

  @override
  void initState() {
    super.initState();
    _bookingHistoryFuture =
        _bookingHistoryService
            .getBookingHistory(); // Memulai pengambilan riwayat pemesanan
    debugPrint(
      'MyBookingsScreen: Memulai pengambilan riwayat pemesanan di initState...', // Diubah
    );
  }

  // Fungsi untuk menangani aksi pull-to-refresh
  Future<void> _refreshBookingHistory() async {
    debugPrint('MyBookingsScreen: Pull-to-refresh dipicu.'); // Diubah
    setState(() {
      _bookingHistoryFuture =
          _bookingHistoryService
              .getBookingHistory(); // Memulai pengambilan ulang
    });
    // Menunggu future selesai agar RefreshIndicator tahu kapan harus berhenti
    await _bookingHistoryFuture;
    debugPrint(
      'MyBookingsScreen: Riwayat pemesanan berhasil diperbarui!',
    ); // Diubah
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2233),
      appBar: AppBar(
        title: const Text('Riwayat Pemesanan Saya'), // Diubah
        centerTitle: true,
        backgroundColor: const Color(0xFF1A2233),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              // Menggunakan context.canPop() dari go_router
              context.pop(); // Menggunakan context.pop() dari go_router
            } else {
              debugPrint(
                'MyBookingsScreen: Tidak ada halaman sebelumnya untuk di-pop.', // Diubah
              );
              // Contoh: Jika ini halaman pertama setelah login, bisa arahkan ke home atau keluar aplikasi
              // context.go('/home');
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBookingHistory,
        child: FutureBuilder<BookingHistoryResponse>(
          future: _bookingHistoryFuture, // Future yang kita tunggu
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              debugPrint(
                'MyBookingsScreen: ConnectionState.waiting - menampilkan CircularProgressIndicator.', // Diubah
              );
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              debugPrint(
                'MyBookingsScreen: snapshot.hasError - ${snapshot.error}',
              );
              // Tampilkan pesan error dan tombol coba lagi
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Terjadi Kesalahan: ${snapshot.error}', // Diubah
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _refreshBookingHistory(); // Coba lagi pengambilan data saat tombol ditekan
                          debugPrint(
                            'MyBookingsScreen: Mencoba ulang pengambilan data saat tombol error diketuk.', // Diubah
                          );
                        },
                        child: const Text('Coba Lagi'), // Diubah
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final bookings = snapshot.data!.data; // Akses daftar item booking
              debugPrint(
                'MyBookingsScreen: Data dimuat. Jumlah booking: ${bookings.length}', // Diubah
              );

              if (bookings.isEmpty) {
                // Jika tidak ada booking, pastikan RefreshIndicator tetap berfungsi dengan menggunakan widget yang dapat di-scroll
                return ListView(
                  children: const [
                    SizedBox(
                      height: 100,
                    ), // Tambahkan spasi untuk penempatan di tengah secara visual
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Anda tidak memiliki pemesanan yang lalu atau akan datang.', // Diubah
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            'Pesan layanan untuk melihatnya di sini!', // Diubah
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Tampilkan daftar booking menggunakan ListView.builder
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  // Format waktu booking untuk tampilan yang mudah dibaca pengguna
                  final formattedTime = DateFormat(
                    'EEEE, dd MMMM yyyy HH:mm', // Ditambah tahun untuk kejelasan
                  ).format(booking.bookingTime.toLocal());

                  // Tentukan warna status untuk umpan balik visual
                  Color statusColor;
                  switch (booking.status.toLowerCase()) {
                    case 'pending':
                      statusColor = Colors.orange[700]!;
                      break;
                    case 'confirmed':
                      statusColor = Colors.green[700]!;
                      break;
                    case 'cancelled':
                      statusColor = Colors.red[700]!;
                      break;
                    case 'completed':
                      statusColor = Colors.blue[700]!;
                      break;
                    default:
                      statusColor = Colors.grey[700]!;
                  }

                  return Card(
                    color: const Color(0xFF2B3A4F),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Layanan: ${booking.service.name}', // Diubah
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deskripsi: ${booking.service.description}', // Diubah
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Harga: Rp${NumberFormat('#,##0', 'id_ID').format(double.parse(booking.service.price))}', // Diubah, menggunakan NumberFormat
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Terjadwal: $formattedTime', // Diubah
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status: ${booking.status.toUpperCase()}', // Diubah
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Opsional: Tambahkan aksi seperti "Batalkan Pemesanan" atau "Lihat Detail"
                          if (booking.status.toLowerCase() == 'pending')
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Hanya izinkan pembaruan jika status 'pending' misalnya
                                      if (booking.status.toLowerCase() ==
                                          'pending') {
                                        // --- Navigasi ke UpdateBookingScreen, meneruskan item booking ---
                                        if (mounted) {
                                          context.push(
                                            '/update_booking_detail', // Ini adalah path GoRouter
                                            extra:
                                                booking, // Teruskan seluruh item booking sebagai 'extra'
                                          );
                                          debugPrint(
                                            'MyBookingsScreen: Navigasi ke /update_booking_detail dengan booking ID: ${booking.id}', // Diubah
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Tidak dapat memperbarui pemesanan berstatus ${booking.status}.', // Diubah
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        debugPrint(
                                          'MyBookingsScreen: Mencoba memperbarui booking yang tidak pending. Status: ${booking.status}', // Diubah
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Perbarui Pemesanan', // Diubah
                                      style: TextStyle(
                                        color: Colors.amber,
                                      ), // Diubah warna agar lebih jelas
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Bagian tombol hapus yang dikomentari, sesuaikan jika akan diaktifkan
                                // Align(
                                //   alignment: Alignment.bottomRight,
                                //   child: TextButton(
                                //     onPressed: () {
                                //       if (booking.status.toLowerCase() == 'pending' || booking.status.toLowerCase() == 'cancelled') {
                                //         _showDeleteConfirmationDialog(booking); // Tampilkan dialog konfirmasi
                                //       } else {
                                //         ScaffoldMessenger.of(context).showSnackBar(
                                //           SnackBar(
                                //             content: Text('Tidak dapat menghapus pemesanan berstatus ${booking.status}.'), // Diubah
                                //             backgroundColor: Colors.orange,
                                //           ),
                                //         );
                                //         debugPrint('MyBookingsScreen: Mencoba menghapus booking yang tidak memenuhi syarat. Status: ${booking.status}',);
                                //       }
                                //     },
                                //     child: const Text(
                                //       'Hapus Pemesanan', // Diubah
                                //       style: TextStyle(color: Colors.red),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text('Tidak ada data.'),
            ); // Fallback untuk status kosong awal
          },
        ),
      ),
    );
  }
}
