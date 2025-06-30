// Lokasi: lib/widgets/promo_card.dart

import 'package:flutter/material.dart';

class PromoCard extends StatelessWidget {
  // Tambahkan properti untuk data yang ingin ditampilkan
  final String title;
  final String discountText;
  final String description;
  // final String imagePath;

  const PromoCard({
    super.key,
    required this.title,
    required this.discountText,
    required this.description,
    // required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ), // Margin horizontal antar Card dalam carousel
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 100, // Tinggi Card bisa disesuaikan
        width:
            MediaQuery.of(context).size.width *
            0.8, // Lebar Card (misal 80% dari lebar layar)
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Expanded(
              flex:
                  3, // Ditingkatkan untuk memberi lebih banyak ruang pada teks
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title, // Gunakan properti title
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        '$discountText', // Tampilkan angka diskon dengan persen
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        description, // Gunakan properti description
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Expanded(
            //   flex: 2, // Disesuaikan agar rasio gambar lebih besar
            //   child: Image.asset(
            //     imagePath, // Gunakan properti imagePath
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) {
            //       return Container(
            //         color: Colors.grey[200],
            //         child: const Icon(
            //           Icons.image_not_supported,
            //           size: 50,
            //           color: Colors.grey,
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
