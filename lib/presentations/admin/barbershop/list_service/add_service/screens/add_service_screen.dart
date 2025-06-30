import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar
import 'dart:io'; // Untuk File
// import 'package:go_router/go_router.dart'; // Untuk navigasi (jika digunakan)
import 'package:flutter/foundation.dart'; // Untuk debugPrint
// Pastikan import model AddServiceResponse Anda sesuai dengan lokasi file:
import 'package:barbershop2/presentations/admin/barbershop/list_service/add_service/models/add_service_models.dart';
// Pastikan import service ServiceManagementService Anda sesuai dengan lokasi file:
import 'package:barbershop2/presentations/admin/barbershop/list_service/add_service/service/add_service_service.dart';

class AddBooking extends StatefulWidget {
  const AddBooking({super.key});

  @override
  State<AddBooking> createState() => _AddBookingState();
}

class _AddBookingState extends State<AddBooking> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk form validation
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();

  File? _employeePhotoFile; // File foto karyawan yang dipilih
  File? _servicePhotoFile; // File foto layanan yang dipilih

  bool _isLoading = false;
  String? _statusMessage; // Untuk menampilkan pesan sukses/error
  final ServiceManagementService _service =
      ServiceManagementService(); // Instansiasi service Anda

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _employeeNameController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage(
    ImageSource source, {
    required bool isEmployeePhoto,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isEmployeePhoto) {
          _employeePhotoFile = File(pickedFile.path);
          debugPrint(
            'AddBooking: FOTO KARYAWAN DIPILIH. Path: ${_employeePhotoFile!.path}',
          );
        } else {
          _servicePhotoFile = File(pickedFile.path);
          debugPrint(
            'AddBooking: FOTO LAYANAN DIPILIH. Path: ${_servicePhotoFile!.path}',
          );
        }
      });
    } else {
      debugPrint('AddBooking: Pemilihan gambar dibatalkan oleh pengguna.');
    }
  }

  // Fungsi untuk menangani proses penambahan layanan
  Future<void> _addService() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('AddBooking: Validasi form gagal. Isi semua kolom wajib.');
      return;
    }

    // --- PENTING: Debugging di sini ---
    debugPrint('AddBooking: Memeriksa keberadaan file foto sebelum dikirim...');
    if (_employeePhotoFile == null || !await _employeePhotoFile!.exists()) {
      _showSnackBar(
        'Pilih foto karyawan terlebih dahulu atau file tidak ada.',
        Colors.red,
      );
      debugPrint(
        'AddBooking: ERROR: Foto karyawan NULL atau TIDAK ADA di path: ${_employeePhotoFile?.path}',
      );
      return;
    }
    if (_servicePhotoFile == null || !await _servicePhotoFile!.exists()) {
      _showSnackBar(
        'Pilih foto layanan terlebih dahulu atau file tidak ada.',
        Colors.red,
      );
      debugPrint(
        'AddBooking: ERROR: Foto layanan NULL atau TIDAK ADA di path: ${_servicePhotoFile?.path}',
      );
      return;
    }
    debugPrint(
      'AddBooking: FOTO KARYAWAN DITEMUKAN di path: ${_employeePhotoFile!.path}',
    );
    debugPrint(
      'AddBooking: FOTO LAYANAN DITEMUKAN di path: ${_servicePhotoFile!.path}',
    );

    setState(() {
      _isLoading = true;
      _statusMessage = null; // Reset pesan status
    });

    try {
      final int price = int.parse(
        _priceController.text,
      ); // Pastikan harga adalah int

      debugPrint(
        'AddBooking: Memulai panggilan API addService dengan data valid...',
      );
      final AddServiceResponse response = await _service.addService(
        name: _nameController.text,
        description: _descriptionController.text,
        price: price,
        employeeName: _employeeNameController.text,
        employeePhotoPath:
            _employeePhotoFile!.path, // Ini sekarang aman karena kita sudah cek
        servicePhotoPath:
            _servicePhotoFile!.path, // Ini sekarang aman karena kita sudah cek
      );

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Berhasil: ${response.message}! Layanan baru ID: ${response.data.id}';
        _showSnackBar(_statusMessage!, Colors.green);
        debugPrint(
          'AddBooking: Layanan berhasil ditambahkan. Respons API sukses.',
        );

        // Opsional: Kosongkan form setelah sukses
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _employeeNameController.clear();
        _employeePhotoFile = null;
        _servicePhotoFile = null;
      });

      // Opsional: Navigasi kembali atau ke daftar layanan setelah sukses
      if (mounted) {
        // context.pop(); // Kembali ke layar sebelumnya
        // context.go('/admin_services'); // Navigasi ke daftar layanan admin
      }
    } catch (e) {
      debugPrint('AddBooking: KESALAHAN UMUM saat menambahkan layanan: $e');
      setState(() {
        _isLoading = false;
        // Hanya tampilkan pesan error dari Exception
        _statusMessage =
            'Gagal: ${e.toString().replaceFirst('Exception: ', '')}';
        _showSnackBar(_statusMessage!, Colors.red);
      });
    }
  }

  // Helper untuk menampilkan SnackBar
  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Layanan Baru'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Layanan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cut),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama layanan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Layanan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _employeeNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Karyawan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama karyawan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Tombol untuk pilih foto karyawan
              ElevatedButton.icon(
                onPressed:
                    () =>
                        _pickImage(ImageSource.gallery, isEmployeePhoto: true),
                icon: const Icon(Icons.image),
                label: const Text('Pilih Foto Karyawan (Galeri)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_employeePhotoFile != null)
                Text(
                  'Foto Karyawan: ${_employeePhotoFile!.path.split('/').last}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              else
                const Text(
                  'Belum ada foto karyawan yang dipilih.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              const SizedBox(height: 16),
              // Tombol untuk pilih foto layanan
              ElevatedButton.icon(
                onPressed:
                    () =>
                        _pickImage(ImageSource.gallery, isEmployeePhoto: false),
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih Foto Layanan (Galeri)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_servicePhotoFile != null)
                Text(
                  'Foto Layanan: ${_servicePhotoFile!.path.split('/').last}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              else
                const Text(
                  'Belum ada foto layanan yang dipilih.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),

              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _addService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Warna tombol utama
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Tambah Layanan',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
              const SizedBox(height: 16),
              if (_statusMessage != null)
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _statusMessage!.startsWith('Berhasil')
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
