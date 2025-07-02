import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Untuk securely getting the token
import 'dart:io'; // Untuk SocketException
import 'dart:async'; // Untuk TimeoutException

// Import model respons delete yang telah kita buat
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/delete/models/delete_model.dart'; // <<< PASTIKAN PATH INI BENAR

// Definisi base URL Anda
const String baseUrl = 'https://appsalon.mobileprojp.com'; // Ganti dengan URL API Anda yang sebenarnya

class DeleteApiService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Melakukan permintaan HTTP DELETE untuk menghapus resource tertentu.
  /// resourcePath: Contoh '/api/bookings/123' atau '/api/services/456'
  ///
  /// Mengembalikan DeleteBookingResponse jika berhasil.
  Future<DeleteBookingResponse> deleteResource({required String resourcePath}) async {
    final url = Uri.parse('$baseUrl$resourcePath');
    debugPrint('DeleteApiService: Attempting to delete resource at: $url');

    try {
      // Ambil token otentikasi dari secure storage
      final String? token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        debugPrint('DeleteApiService: Authentication token not found. Cannot delete resource.');
        throw Exception('Authentication token not found. Please log in.');
      }

      debugPrint('DeleteApiService: Found token. Making DELETE request with Authorization header.');

      // Lakukan permintaan HTTP DELETE
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json', // Memberi tahu server kita menginginkan JSON
          'Authorization': 'Bearer $token', // Sertakan token otentikasi
        },
      ).timeout(const Duration(seconds: 10)); // Tambahkan timeout untuk mencegah permintaan tak terbatas

      debugPrint('DeleteApiService: Delete Resource Response Status Code: ${response.statusCode}');
      debugPrint('DeleteApiService: Delete Resource Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Jika respons 200 OK, parse data
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Menggunakan factory constructor fromJson dari DeleteBookingResponse
        final DeleteBookingResponse deleteResponse = DeleteBookingResponse.fromJson(responseData);
        debugPrint('DeleteApiService: Resource deleted successfully! Message: ${deleteResponse.message}');
        return deleteResponse;
      } else if (response.statusCode == 401) {
        // Tangani Unauthorized (token tidak valid/kadaluarsa)
        debugPrint('DeleteApiService: Unauthorized access (401). Token might be expired or invalid.');
        throw Exception(
            'Unauthorized. Your session may have expired. Please log in again.');
      } else if (response.statusCode == 404) {
        // Tangani Not Found (resource tidak ditemukan)
        debugPrint('DeleteApiService: Resource not found (404) at path: $resourcePath.');
        throw Exception('Resource tidak ditemukan.');
      } else {
        // Tangani kode status HTTP lainnya (misal: 400, 500)
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Gagal menghapus resource.';
        
        // Coba ekstrak pesan error lebih detail dari 'errors' jika ada
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${(value as List).join(', ')}'; // Menggabungkan pesan error dari array
          });
        }
        debugPrint('DeleteApiService: API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // Tangani error koneksi internet
      debugPrint('DeleteApiService: Network error (SocketException): ${e.message}');
      throw Exception('Tidak ada koneksi internet. Mohon periksa koneksi Anda.');
    } on TimeoutException catch (e) {
      // Tangani error jika permintaan habis waktu
      debugPrint('DeleteApiService: Request timed out (TimeoutException): $e');
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      // Tangani error tak terduga lainnya
      debugPrint('DeleteApiService: An unexpected error occurred: $e');
      throw Exception('Terjadi kesalahan tidak terduga: ${e.toString()}');
    }
  }
}