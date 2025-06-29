// Lokasi: lib/presentations/user/home/screens/widget/latest_booking_card.dart

import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// <<< HAPUS IMPOR MODEL BOOKING HISTORY ATAU DISPLAY LAINNYA >>>
// import 'package:barbershop2/models/booking_history_models/booking_history_item.dart';
// import 'package:barbershop2/models/latest_booking_display_data.dart';


class LatestBookingCard extends StatelessWidget {
  // <<< UBAH PROPERTI INI UNTUK MENERIMA DATA LANGSUNG >>>
  final String serviceName;
  final String servicePhotoUrl;
  final DateTime bookingTime;
  final String status;
  final String description; // Menambahkan deskripsi untuk tampilan yang lebih lengkap
  final String price; // Menambahkan harga untuk tampilan yang lebih lengkap


  const LatestBookingCard({
    super.key,
    required this.serviceName,
    required this.servicePhotoUrl,
    required this.bookingTime,
    required this.status,
    required this.description,
    required this.price,
  });


  @override
  Widget build(BuildContext context) {
    final formattedBookingTime = DateFormat('dd MMM, HH:mm').format(bookingTime.toLocal()); // Gunakan bookingTime langsung
    
    Color statusColor;
    switch (status.toLowerCase()) { // Gunakan status langsung
      case 'pending': statusColor = Colors.orange[700]!; break;
      case 'confirmed': statusColor = Colors.green[700]!; break;
      case 'cancelled': statusColor = Colors.red[700]!; break;
      case 'completed': statusColor = Colors.blue[700]!; break;
      default: statusColor = Colors.grey[700]!;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // <<< HAPUS ATAU UBAH LOGIKA NAVIGASI DI SINI, FOKUS KE TAMPILAN SAJA >>>
          debugPrint('LatestBookingCard: Kartu diklik (tampilan saja).');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ini hanya tampilan UI Card!')),
          );
        },
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              // Bagian Kiri (Gambar Layanan)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey[100],
                  child: servicePhotoUrl.isNotEmpty // Gunakan servicePhotoUrl langsung
                      ? Image.network(
                          servicePhotoUrl, // Gunakan servicePhotoUrl langsung
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('LatestBookingCard: Error memuat gambar layanan $serviceName: $error');
                            return Center(
                              child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
                            );
                          },
                        )
                      : Center(
                          child: Icon(Icons.cut, size: 60, color: Colors.grey[400]),
                        ),
                ),
              ),
              // Bagian Kanan (Detail Booking)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Judul/Nama Booking
                      const Text(
                        'Booking Terbaru',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Nama Layanan
                      Text(
                        serviceName, // Gunakan serviceName langsung
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      // Waktu Booking
                      Text(
                        formattedBookingTime,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Status Booking
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          status.toUpperCase(), // Gunakan status langsung
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Tombol Aksi (misal: "Lihat Detail")
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // <<< HAPUS ATAU UBAH LOGIKA NAVIGASI DI SINI >>>
                            debugPrint('LatestBookingCard: Tombol Update diklik (tampilan saja).');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tombol ini hanya untuk UI!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Lihat Detail'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}