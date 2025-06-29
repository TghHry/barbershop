import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk mendapatkan token secara aman
import 'dart:io';   // Untuk kelas File dan SocketException
import 'dart:async'; // Untuk TimeoutException

// Impor model AddServiceResponse Anda
// Sesuaikan path sesuai struktur proyek Anda
import 'package:barbershop2/presentations/admin/barbershop/list_service/add_service/models/add_service_models.dart';

// Definisikan BASE URL Anda (pastikan konsisten di semua layanan Anda)
const String baseUrl = 'https://appsalon.mobileprojp.com'; // Ganti dengan BASE URL aktual Anda

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
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint('ServiceManagementService: Token otentikasi tidak ditemukan. Tidak dapat menambahkan layanan.');
        throw Exception('Token otentikasi tidak ditemukan. Silakan login.');
      }

      debugPrint('ServiceManagementService: Token ditemukan. Membuat permintaan multipart.');

      // Buat MultipartRequest untuk upload file
      var request = http.MultipartRequest('POST', url);

      // Tambahkan header otorisasi
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json'; // Meminta respons JSON

      // Tambahkan field teks
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['price'] = price.toString(); // Konversi harga int ke string untuk field form
      request.fields['employee_name'] = employeeName;

      // Tambahkan file gambar
      // Foto Karyawan
      if (employeePhotoPath.isNotEmpty) {
        final employeePhotoFile = File(employeePhotoPath);
        if (!await employeePhotoFile.exists()) {
          debugPrint('ServiceManagementService: File foto karyawan tidak ada: $employeePhotoPath');
          throw Exception('File foto karyawan tidak ada di: $employeePhotoPath');
        }
        request.files.add(await http.MultipartFile.fromPath(
          'employee_photo', // Ini adalah nama field di API Anda (Laravel sering menggunakan snake_case)
          employeePhotoPath,
          filename: employeePhotoFile.path.split('/').last, // Ambil hanya nama file
        ));
        debugPrint('ServiceManagementService: Menambahkan file foto karyawan.');
      }

      // Foto Layanan
      if (servicePhotoPath.isNotEmpty) {
        final servicePhotoFile = File(servicePhotoPath);
        if (!await servicePhotoFile.exists()) {
          debugPrint('ServiceManagementService: File foto layanan tidak ada: $servicePhotoPath');
          throw Exception('File foto layanan tidak ada di: $servicePhotoPath');
        }
        request.files.add(await http.MultipartFile.fromPath(
          'service_photo', // Ini adalah nama field di API Anda
          servicePhotoPath,
          filename: servicePhotoFile.path.split('/').last,
        ));
        debugPrint('ServiceManagementService: Menambahkan file foto layanan.');
      }

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
      } else if (response.statusCode == 401) {
        debugPrint('ServiceManagementService: Akses tidak sah (401). Token mungkin kedaluwarsa atau tidak valid.');
        throw Exception('Tidak sah. Sesi Anda mungkin telah berakhir. Silakan login lagi.');
      } else {
        // Tangani error API lainnya
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Gagal menambahkan layanan. Silakan coba lagi.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}'; // Asumsi error adalah array string
          });
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