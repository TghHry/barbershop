import 'dart:convert';
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_models/list_service_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk securely getting the token
import 'dart:io'; // Untuk SocketException
import 'dart:async'; // Untuk TimeoutException

// Import model yang baru Anda buat
// import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_models/service_list_response_model.dart';
// Jika ServiceListResponseModel sudah mengimpor ServiceItemModel,
// Anda mungkin tidak perlu mengimpor ServiceItemModel secara eksplisit di sini.

// Definisi base URL Anda
const String baseUrl =
    'https://appsalon.mobileprojp.com'; // Ganti dengan URL API Anda yang sebenarnya

class ServiceListService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Mengambil daftar layanan dari API.
  /// Membutuhkan token otentikasi dari FlutterSecureStorage.
  Future<ServiceListResponse> getServiceList() async {
    final url = Uri.parse(
      '$baseUrl/api/services',
    ); // Asumsi endpoint API untuk daftar layanan
    debugPrint(
      'ServiceListService: Attempting to fetch service list from: $url',
    );

    try {
      // Ambil token otentikasi dari secure storage
      final String? token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        debugPrint(
          'ServiceListService: Authentication token not found. Cannot fetch service list.',
        );
        throw Exception('Authentication token not found. Please log in.');
      }

      debugPrint(
        'ServiceListService: Found token. Making GET request with Authorization header.',
      );

      // Lakukan permintaan HTTP GET
      final response = await http
          .get(
            url,
            headers: {
              'Accept':
                  'application/json', // Memberi tahu server kita menginginkan JSON
              'Authorization': 'Bearer $token', // Sertakan token otentikasi
            },
          )
          .timeout(
            const Duration(seconds: 15),
          ); // Tambahkan timeout untuk mencegah permintaan tak terbatas

      debugPrint(
        'ServiceListService: Response Status Code: ${response.statusCode}',
      );
      debugPrint('ServiceListService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Jika respons 200 OK, parse data
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Menggunakan factory constructor fromJson dari ServiceListResponse
        final ServiceListResponse serviceListResponse =
            ServiceListResponse.fromJson(responseData);
        debugPrint(
          'ServiceListService: Successfully parsed service list response.',
        );
        return serviceListResponse;
      } else if (response.statusCode == 401) {
        // Tangani Unauthorized (token tidak valid/kadaluarsa)
        debugPrint(
          'ServiceListService: Unauthorized access (401). Token might be expired or invalid.',
        );
        throw Exception(
          'Unauthorized. Your session may have expired. Please log in again.',
        );
      } else {
        // Tangani kode status HTTP lainnya (misal: 400, 404, 500)
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Failed to fetch service list.';

        // Coba ekstrak pesan error lebih detail dari 'errors' jika ada
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage +=
                '\n${(value as List).join(', ')}'; // Menggabungkan pesan error dari array
          });
        }
        debugPrint('ServiceListService: API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // Tangani error koneksi internet
      debugPrint(
        'ServiceListService: Network error (SocketException): ${e.message}',
      );
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda.',
      );
    } on TimeoutException catch (e) {
      // Tangani error jika permintaan habis waktu
      debugPrint(
        'ServiceListService: Request timed out (TimeoutException): $e',
      );
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      // Tangani error tak terduga lainnya
      debugPrint('ServiceListService: An unexpected error occurred: $e');
      throw Exception('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }
}
