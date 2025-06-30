import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For securely getting the token
import 'dart:io';    // For File class and SocketException
import 'dart:async'; // For TimeoutException
import 'dart:typed_data'; // For Uint8List and Base64 conversion

// Impor model AddServiceResponse Anda
// Sesuaikan path sesuai struktur proyek Anda
import 'package:barbershop2/presentations/admin/barbershop/home/add_service/models/add_service_models.dart';

// Definisikan BASE URL Anda (pastikan konsisten di semua layanan Anda)
const String baseUrl = 'https://appsalon.mobileprojp.com'; // Your actual base URL

class ServiceManagementService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Metode untuk menambahkan layanan baru dengan upload gambar
  Future<AddServiceResponse> addService({
    required String name,
    required String description,
    required int price, // Harga adalah int di respons, jadi dikirim sebagai int
    required String employeeName,
    required String employeePhotoPath, // Path ke file foto karyawan lokal
    required String servicePhotoPath,  // Path ke file foto layanan lokal
  }) async {
    final url = Uri.parse('$baseUrl/api/services');
    debugPrint('ServiceManagementService: Mencoba menambahkan layanan baru...');
    debugPrint('ServiceManagementService: URL: $url');
    debugPrint('ServiceManagementService: Detail Layanan: Nama=$name, Harga=$price, Karyawan=$employeeName');
    debugPrint('ServiceManagementService: Path Foto Karyawan: $employeePhotoPath');
    debugPrint('ServiceManagementService: Path Foto Layanan: $servicePhotoPath');

    try {
      // Ambil token otentikasi dari penyimpanan aman
      final String? token = await _secureStorage.read(key: 'auth_token'); // Menggunakan kunci yang konsisten
      if (token == null || token.isEmpty) {
        debugPrint('ServiceManagementService: Token otentikasi tidak ditemukan. Tidak dapat menambahkan layanan.');
        throw Exception('Token otentikasi tidak ditemukan. Silakan login.');
      }

      debugPrint('ServiceManagementService: Token ditemukan. Membuat permintaan multipart.');

      // Buat MultipartRequest untuk upload file
      var request = http.MultipartRequest('POST', url);

      // Tambahkan header otorisasi
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json'; // Meminta respons JSON
      // MultipartRequest secara otomatis mengatur Content-Type: multipart/form-data
      // Tidak perlu menyetel 'Content-Type': 'application/json' di sini untuk request.headers

      // Tambahkan field teks
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString(); // Konversi harga int ke string untuk field form
      request.fields['employee_name'] = employeeName;

      // --- PERUBAHAN UTAMA: Konversi gambar ke Base64 dan tambahkan ke request.fields ---
      // Foto Karyawan
      if (employeePhotoPath.isNotEmpty) {
        final employeePhotoFile = File(employeePhotoPath);
        if (!await employeePhotoFile.exists()) {
          debugPrint('ServiceManagementService: File foto karyawan tidak ada: $employeePhotoPath');
          throw Exception('File foto karyawan tidak ada di: $employeePhotoPath');
        }
        Uint8List employeePhotoBytes = await employeePhotoFile.readAsBytes();
        String employeePhotoBase64 = base64Encode(employeePhotoBytes);
        request.fields['employee_photo'] = employeePhotoBase64; // Kirim Base64 sebagai string
        debugPrint('ServiceManagementService: Foto karyawan dikonversi ke Base64 dan ditambahkan ke fields.');
      } else {
        request.fields['employee_photo'] = ''; // Kirim string kosong jika tidak ada foto
        debugPrint('ServiceManagementService: Path foto karyawan kosong. Mengirim string kosong untuk field.');
      }

      // Foto Layanan
      if (servicePhotoPath.isNotEmpty) {
        final servicePhotoFile = File(servicePhotoPath);
        if (!await servicePhotoFile.exists()) {
          debugPrint('ServiceManagementService: File foto layanan tidak ada: $servicePhotoPath');
          throw Exception('File foto layanan tidak ada di: $servicePhotoPath');
        }
        Uint8List servicePhotoBytes = await servicePhotoFile.readAsBytes();
        String servicePhotoBase64 = base64Encode(servicePhotoBytes);
        request.fields['service_photo'] = servicePhotoBase64; // Kirim Base64 sebagai string
        debugPrint('ServiceManagementService: Foto layanan dikonversi ke Base64 dan ditambahkan ke fields.');
      } else {
        request.fields['service_photo'] = ''; // Kirim string kosong jika tidak ada foto
        debugPrint('ServiceManagementService: Path foto layanan kosong. Mengirim string kosong untuk field.');
      }
      // --- AKHIR PERUBAHAN UTAMA ---

      // --- CATATAN: request.files.add() DIHAPUS karena kita mengirim Base64 di request.fields ---
      
      debugPrint('ServiceManagementService: Mengirim permintaan multipart...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse); // Konversi streamed response ke http.Response

      debugPrint('ServiceManagementService: Kode Status Respons: ${response.statusCode}');
      debugPrint('ServiceManagementService: Body Respons: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Penambahan layanan berhasil
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('ServiceManagementService: Layanan berhasil ditambahkan! Parsing respons...');
        final AddServiceResponse addServiceResponse = AddServiceResponse.fromJson(responseData);
        debugPrint('ServiceManagementService: ID Layanan Baru yang Diparsing: ${addServiceResponse.data.id}');
        return addServiceResponse;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('ServiceManagementService: Akses tidak sah (${response.statusCode}). Token mungkin kedaluwarsa atau tidak valid.');
        await _secureStorage.delete(key: 'auth_token'); // Hapus token kadaluarsa/tidak valid
        throw Exception('Tidak sah. Sesi Anda mungkin telah berakhir. Silakan login lagi.');
      } else if (response.statusCode == 422) { // Kode status umum untuk error validasi
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Gagal menambahkan layanan karena validasi server.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessage += '\n- ${value[0]}'; // Asumsi error adalah array string
            } else if (value is String) {
              errorMessage += '\n- $value';
            }
          });
        }
        debugPrint('ServiceManagementService: Error Validasi API (422): $errorMessage');
        throw Exception(errorMessage);
      }
      else {
        // Tangani error API lainnya
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Gagal menambahkan layanan. Silakan coba lagi.';
        // Tangani error jika ada di field 'errors' umum
        if (errorData.containsKey('errors') && errorData['errors'] is String) {
          errorMessage += '\n${errorData['errors']}';
        }
        debugPrint('ServiceManagementService: Error API: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      debugPrint('ServiceManagementService: Error jaringan (SocketException): ${e.message}');
      throw Exception('Tidak ada koneksi internet. Mohon periksa koneksi Anda.');
    } on TimeoutException catch (e) {
      debugPrint('ServiceManagementService: Permintaan habis waktu (TimeoutException): $e');
      throw Exception('Permintaan ke server habis waktu. Silakan coba lagi.');
    } catch (e) {
      debugPrint('ServiceManagementService: Terjadi error tidak terduga: $e');
      throw Exception('Terjadi kesalahan tidak terduga: ${e.toString()}'); // Tambahkan e.toString() untuk detail
    }
  }
}
