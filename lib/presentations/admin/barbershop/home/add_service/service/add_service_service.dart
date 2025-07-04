import 'dart:convert'; // Import untuk json.encode dan json.decode
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For securely getting the token
import 'dart:io'; // Untuk SocketException
import 'dart:async'; // Untuk TimeoutException

// Impor model AddServiceResponse Anda
import 'package:barbershop2/presentations/admin/barbershop/home/add_service/models/add_service_models.dart';

// Definisikan BASE URL Anda (pastikan konsisten di semua layanan Anda)
const String baseUrl =
    'https://appsalon.mobileprojp.com'; // Your actual base URL

class ServiceManagementService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Metode untuk menambahkan layanan baru dengan upload gambar sebagai Base64
  Future<AddServiceResponse> addService({
    required String name,
    required String description,
    required int price,
    required String employeeName,
    required String
        servicePhotoBase64, // Parameter sekarang adalah Base64 string
  }) async {
    final url = Uri.parse('$baseUrl/api/services');
    debugPrint('ServiceManagementService: Mencoba menambahkan layanan baru...');
    debugPrint('ServiceManagementService: URL: $url');
    debugPrint(
        'ServiceManagementService: Detail Layanan: Nama=$name, Harga=$price, Karyawan=$employeeName',
    );
    debugPrint(
        'ServiceManagementService: Panjang Base64 Foto Layanan: ${servicePhotoBase64.length}',
    );

    try {
      // Ambil token otentikasi dari penyimpanan aman
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        debugPrint(
            'ServiceManagementService: Token otentikasi tidak ditemukan. Tidak dapat menambahkan layanan.',
        );
        throw Exception('Token otentikasi tidak ditemukan. Silakan login.');
      }

      debugPrint(
          'ServiceManagementService: Token ditemukan. Membuat permintaan POST dengan JSON body.',
      );

      // Buat body permintaan dalam format Map
      final Map<String, dynamic> requestBody = {
        'name': name,
        'description': description,
        'price': price, // Harga dikirim sebagai int
        'employee_name': employeeName,
        'service_photo': servicePhotoBase64,
      };

      debugPrint(
          'ServiceManagementService: Body Permintaan JSON: ${json.encode(requestBody)}',
      );

      // Kirim permintaan HTTP POST
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type':
                  'application/json', // Menunjukkan bahwa body adalah JSON
              'Authorization': 'Bearer $token',
              'Accept': 'application/json', // Meminta respons JSON
            },
            body: json.encode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
          ); // Tambahkan timeout untuk mencegah permintaan menggantung

      debugPrint(
          'ServiceManagementService: Kode Status Respons: ${response.statusCode}',
      );
      debugPrint('ServiceManagementService: Body Respons: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
        // Penambahan layanan berhasil
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint(
            'ServiceManagementService: Layanan berhasil ditambahkan! Parsing respons...',
        );
        final AddServiceResponse addServiceResponse =
            AddServiceResponse.fromJson(responseData);
        
        // --- PERUBAHAN DI SINI UNTUK MENGHILANGKAN WARNING ---
        // Karena Dart sekarang mengerti bahwa addServiceResponse.data tidak bisa null
        // DAN addServiceResponse.data.id juga tidak bisa null (berdasarkan model terbaru Anda)
        debugPrint(
            'ServiceManagementService: ID Layanan Baru yang Diparsing: ${addServiceResponse.data.id}', // Hapus '!' dan '??'
        );
        // --- AKHIR PERUBAHAN ---

        return addServiceResponse;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint(
            'ServiceManagementService: Akses tidak sah (${response.statusCode}). Token mungkin kedaluwarsa atau tidak valid.',
        );
        await _secureStorage.delete(
            key: 'auth_token',
        ); // Hapus token kadaluarsa/tidak valid
        throw Exception(
            'Tidak sah. Sesi Anda mungkin telah berakhir. Silakan login lagi.',
        );
      } else if (response.statusCode == 422) {
        // Kode status umum untuk error validasi
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ??
            'Gagal menambahkan layanan karena validasi server.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessage +=
                  '\n- ${value[0]}'; // Asumsi error adalah array string
            } else if (value is String) {
              errorMessage += '\n- $value';
            }
          });
        }
        debugPrint(
            'ServiceManagementService: Error Validasi API (422): $errorMessage',
        );
        throw Exception(errorMessage);
      } else {
        // Tangani error API lainnya
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ??
            'Gagal menambahkan layanan. Silakan coba lagi.';
        if (errorData.containsKey('errors') && errorData['errors'] is String) {
          errorMessage += '\n${errorData['errors']}';
        }
        debugPrint('ServiceManagementService: Error API: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      debugPrint(
          'ServiceManagementService: Error jaringan (SocketException): ${e.message}',
      );
      throw Exception(
          'Tidak ada koneksi internet. Mohon periksa koneksi Anda.',
      );
    } on TimeoutException catch (e) {
      debugPrint(
          'ServiceManagementService: Permintaan habis waktu (TimeoutException): $e',
      );
      throw Exception('Permintaan ke server habis waktu. Silakan coba lagi.');
    } catch (e) {
      debugPrint('ServiceManagementService: Terjadi error tidak terduga: $e');
      throw Exception('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }
}