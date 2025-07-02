import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_models/list_service_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_service/list_service.dart'; // Import ServiceItem
// import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_service/list_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// Import service delete yang baru Anda buat
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/delete/models/delete_model.dart'; // <<< PASTIKAN PATH INI BENAR
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/delete/services/delete_service.dart'; // Import model respons delete

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  late Future<ServiceListResponse>
  _serviceListFuture; // Future untuk menyimpan hasil API call
  final ServiceListService _serviceListService =
      ServiceListService(); // Inisialisasi service
  final DeleteApiService _deleteApiService =
      DeleteApiService(); // Inisialisasi service delete

  @override
  void initState() {
    super.initState();
    _loadServices(); // Panggil method untuk memuat layanan
  }

  // Metode untuk memuat daftar layanan
  Future<void> _loadServices() async {
    setState(() {
      _serviceListFuture = _serviceListService.getServiceList();
    });
  }

  // Metode untuk menampilkan dialog konfirmasi penghapusan
  Future<void> _showDeleteConfirmationDialog(
    int serviceId,
    String serviceName,
  ) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Latar belakang dialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Konfirmasi Penghapusan',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus layanan "$serviceName"? Aksi ini tidak dapat dibatalkan.',
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Tidak jadi menghapus
              },
              child: const Text(
                'Tidak',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Ya, hapus
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Warna tombol konfirmasi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Jika pengguna mengkonfirmasi penghapusan
      _deleteService(serviceId);
    }
  }

  // Metode untuk melakukan penghapusan layanan
  Future<void> _deleteService(int serviceId) async {
    try {
      if (!mounted) return; // Pastikan widget masih mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menghapus layanan...'),
          duration: Duration(seconds: 2), // Durasi singkat
        ),
      );

      // Panggil deleteResource dari DeleteApiService
      // Asumsi: Endpoint untuk menghapus layanan adalah /api/services/{id}
      final DeleteBookingResponse response = await _deleteApiService
          .deleteResource(resourcePath: '/api/services/$serviceId');
      debugPrint('Service deleted successfully: ${response.message}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Layanan berhasil dihapus: ${response.message}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadServices(); // Refresh daftar setelah penghapusan berhasil
      }
    } catch (e) {
      debugPrint('Failed to delete service: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Tutup SnackBar yang sedang tampil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus Layanan: ${e.toString()}',
            ), // Tampilkan pesan error penuh
            backgroundColor: Colors.red,
          ), // SnackBar
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Layanan'),
        backgroundColor: const Color(0xFF1A2233),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              debugPrint('ServicesListScreen: No previous page to pop.');
            }
          },
        ),
      ),
      backgroundColor: const Color(0xFF1A2233),
      body: RefreshIndicator(
        onRefresh: _loadServices, // Menggunakan _loadServices untuk refresh
        child: FutureBuilder<ServiceListResponse>(
          future: _serviceListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada layanan yang tersedia.',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  final serviceItem = snapshot.data!.data[index];
                  return Card(
                    color: const Color(0xFF2B3A4F),
                    margin: const EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bagian Gambar Layanan (jika ada dan ingin ditampilkan)
                          if (serviceItem.servicePhotoUrl != null &&
                              serviceItem.servicePhotoUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                serviceItem.servicePhotoUrl!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                    'Error loading image for ${serviceItem.name}: $error',
                                  );
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[700],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              height: 100,
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10), // Spasi setelah gambar

                          Text(
                            serviceItem.name ?? 'Nama Layanan Tidak Diketahui',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            serviceItem.description ?? 'Tidak ada deskripsi',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Harga: Rp${serviceItem.price?.toStringAsFixed(0) ?? 'N/A'}', // Format harga
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (serviceItem.employeeName != null &&
                              serviceItem.employeeName!.isNotEmpty)
                            Text(
                              'Barber: ${serviceItem.employeeName}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          if (serviceItem.createdAt != null)
                            Text(
                              'Dibuat: ${serviceItem.createdAt!.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      // Navigasi ke detail booking
                                      context.push(
                                        '/booking_service_detail',
                                        extra: serviceItem,
                                      );
                                      debugPrint(
                                        'Navigating to Booking Detail for ID: ${serviceItem.id}',
                                      );
                                    },
                                    child: const Text(
                                      'Booking layanan ini',
                                      style: TextStyle(
                                        color: Colors.lightBlueAccent,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2), // Spasi antar tombol
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      // Pastikan ID tidak null sebelum mencoba menghapus
                                      if (serviceItem.id != null) {
                                        _showDeleteConfirmationDialog(
                                          serviceItem.id!,
                                          serviceItem.name ?? 'Layanan ini',
                                        );
                                      } else {
                                        debugPrint(
                                          'Service ID is null, cannot delete.',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Tidak dapat menghapus: ID layanan tidak ditemukan.',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Hapus layanan ini',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
