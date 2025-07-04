import 'package:barbershop2/presentations/admin/barbershop/home/add_service/service/add_service_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar
import 'dart:io'; // Untuk kelas File
import 'dart:convert'; // Untuk base64Encode
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// Pastikan path ke ServiceManagementService dan AddServiceResponse/AddServiceData Anda benar
import 'package:barbershop2/presentations/admin/barbershop/home/add_service/models/add_service_models.dart';
// import 'package:barbershop2/presentations/admin/barbershop/home/add_service/service/add_service.dart'; // Ini ServiceManagementService

class AddBookingScreen extends StatefulWidget {
  // Atau AddServiceScreen
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form

  // Controller untuk input teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();

  // File gambar yang dipilih (untuk tampilan UI)
  File? _servicePhotoFile;

  // String Base64 dari gambar (ini yang akan dikirim ke API)
  String? _servicePhotoBase64;

  final ImagePicker _picker = ImagePicker(); // Inisialisasi ImagePicker
  final ServiceManagementService _service =
      ServiceManagementService(); // Inisialisasi service API

  bool _isLoading = false; // Untuk menampilkan loading indicator

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _employeeNameController
        .dispose(); // Still need to dispose as it's a TextEditingController for a text field
    super.dispose();
  }

  // Metode untuk memilih gambar dan mengonversinya ke Base64
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        _servicePhotoFile = file;
        _servicePhotoBase64 = base64String;
      });
      debugPrint(
        'Gambar layanan berhasil dikonversi ke Base64 (panjang: ${base64String.length}).',
      );
    }
  }

  // Metode untuk menangani pengiriman data layanan
  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_servicePhotoBase64 == null) {
      // Tidak perlu cek mounted di sini karena ini terjadi sebelum async gap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih foto layanan.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AddServiceResponse response = await _service.addService(
        name: _nameController.text,
        description: _descriptionController.text,
        price: int.parse(_priceController.text),
        employeeName: _employeeNameController.text,
        servicePhotoBase64: _servicePhotoBase64!,
      );

      // --- PERUBAHAN DI BAGIAN INI ---
      String snackBarMessage;
      // Hapus kondisi 'if (response.data != null)' karena Dart sudah yakin tidak null
      // Jika 'id' di model AddServiceData memang non-nullable, maka tidak perlu '??'
      // Jika 'id' di model AddServiceData masih nullable (contoh: int? id;), maka gunakan '??'
      snackBarMessage = 'Layanan berhasil ditambahkan! ID: ${response.data.id}'; // Gunakan langsung .id
      
      // >>> SOLUSI UNTUK WARNING BuildContext <<<
      if (!mounted) return; // Penting: cek apakah widget masih terpasang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage)),
      );
      // --- AKHIR PERUBAHAN ---

      // Bersihkan form setelah sukses
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _employeeNameController.clear();
      setState(() {
        _servicePhotoFile = null;
        _servicePhotoBase64 = null;
      });

      // Opsional: Lakukan navigasi kembali setelah sukses
      // if (mounted) {
      //   context.pop(); // Kembali ke halaman sebelumnya
      // }
    } catch (e) {
      debugPrint('Error saat submit layanan: $e');
      // >>> SOLUSI UNTUK WARNING BuildContext <<<
      if (!mounted) return; // Penting: cek apakah widget masih terpasang
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan layanan: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Layanan Baru'),
        backgroundColor: const Color(0xFF1A2233),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), // Ikon panah kembali
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              debugPrint(
                'ProfileScreen: Tidak ada halaman sebelumnya untuk di-pop.',
              );
            }
          },
        ),
      ),
      backgroundColor: const Color(0xFF1A2233), // Latar belakang gelap
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Nama Layanan'),
                      style: const TextStyle(color: Colors.white),
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
                      decoration: _inputDecoration('Deskripsi Layanan'),
                      style: const TextStyle(color: Colors.white),
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
                      decoration: _inputDecoration('Harga (IDR)'),
                      style: const TextStyle(color: Colors.white),
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
                      decoration: _inputDecoration('Nama Karyawan'),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama karyawan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // Only keep the service photo section
                    _buildImagePickerSection(
                      'Foto Layanan',
                      _servicePhotoFile,
                      (source) => _pickImage(source), // Removed imageType parameter
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFFD700,
                        ), // Warna emas
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ), // Lebar penuh
                      ),
                      child: const Text(
                        'Tambah Layanan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Dekorasi input yang konsisten
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1A2233), // Latar belakang field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
    );
  }

  // Widget untuk bagian pilih gambar
  Widget _buildImagePickerSection(
    String title,
    File? imageFile,
    Function(ImageSource) onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2233),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 50, color: Colors.white54),
                      Text(
                        'Pilih $title',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onPick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.black),
                label: const Text('Kamera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onPick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Colors.black),
                label: const Text('Galeri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}