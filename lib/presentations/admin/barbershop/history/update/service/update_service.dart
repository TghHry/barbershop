import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage
import 'dart:io'; // For SocketException (opsional, jika Anda ingin menangani secara eksplisit)
import 'dart:async'; // For TimeoutException (opsional, jika Anda ingin menangani secara eksplisit)

// Pastikan Anda mengimpor model-model ini dari lokasi yang benar di proyek Anda.
// Ini adalah file yang berisi kelas UpdatedBookingData dan UpdateBookingResponse
// yang telah diperbaiki (seperti yang Anda tunjukkan di kueri).
import 'package:barbershop2/presentations/admin/barbershop/history/update/models/update_models.dart';

class ApiService {
  // baseUrl Anda telah diperbarui ke nilai yang Anda berikan.
  final String baseUrl = 'https://appsalon.mobileprojp.com';

  // Inisialisasi FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Memperbarui status pemesanan.
  ///
  /// Menerima [bookingId] (ID pemesanan yang akan diperbarui)
  /// dan [status] baru (misalnya, 'confirmed', 'canceled') sebagai input.
  /// Mengembalikan [Future] yang akan menyelesaikan ke objek [UpdateBookingResponse] saat berhasil.
  /// Melempar [Exception] jika panggilan API gagal atau respons tidak valid.
  Future<UpdateBookingResponse> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    final String url = '$baseUrl/api/bookings/$bookingId';
    debugPrint(
      'ApiService: Mencoba memperbarui status pemesanan untuk ID $bookingId ke "$status"',
    );
    debugPrint('ApiService: URL Panggilan: $url');

    try {
      // 1. Ambil token otentikasi dari penyimpanan aman (FlutterSecureStorage)
      // Menggunakan kunci 'auth_token' agar konsisten dengan BookingHistoryService dan LoginScreen.
      final String? authToken = await _secureStorage.read(key: 'auth_token');
      debugPrint(
        'ApiService: Token yang dibaca dari secure storage: ${authToken != null && authToken.isNotEmpty ? 'Ada dan Tidak Kosong' : 'Tidak Ada atau Kosong'}',
      );

      // 2. Buat map headers, termasuk Authorization jika token tersedia
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      if (authToken != null && authToken.isNotEmpty) {
        // Menambahkan token ke header 'Authorization' dengan skema 'Bearer'
        headers['Authorization'] = 'Bearer $authToken';
        debugPrint('ApiService: Header Authorization disiapkan.');
      } else {
        debugPrint(
          'ApiService: Peringatan: Tidak ada token otentikasi ditemukan atau token kosong. Melempar Exception.',
        );
        throw Exception('Autentikasi diperlukan. Harap login kembali.');
      }

      // Melakukan permintaan PUT ke API.
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(<String, String>{'status': status}),
      );

      debugPrint(
        'ApiService: Menerima respons dengan kode status: ${response.statusCode}',
      );
      debugPrint('ApiService: Body respons: ${response.body}');

      // Memeriksa apakah permintaan berhasil (kode status HTTP 2xx).
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Mendekode string respons JSON menjadi Map Dart.
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        debugPrint('ApiService: Mendekode respons JSON.');
        // --- Menggunakan UpdatedBookingResponse.fromJson() yang sudah diperbaiki ---
        return UpdateBookingResponse.fromJson(responseJson);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint(
          'ApiService: Autentikasi gagal atau tidak diizinkan. Kode status: ${response.statusCode}',
        );
        await _secureStorage.delete(
          key: 'auth_token',
        ); // Hapus token kadaluarsa/tidak valid
        throw Exception(
          'Sesi Anda telah berakhir atau tidak memiliki izin. Harap login kembali.',
        );
      } else {
        String errorMessage =
            'Gagal memperbarui pemesanan. Status: ${response.statusCode}.';
        try {
          final Map<String, dynamic> errorJson = jsonDecode(response.body);
          if (errorJson.containsKey('message')) {
            errorMessage = errorJson['message'];
          } else if (errorJson.containsKey('error')) {
            errorMessage = errorJson['error'];
          }
        } catch (e) {
          debugPrint(
            'ApiService: Gagal mendekode body kesalahan sebagai JSON: $e',
          );
          errorMessage =
              'Gagal memperbarui pemesanan. Respons server tidak dapat diuraikan: ${response.body}';
        }

        debugPrint('ApiService: API mengembalikan kesalahan: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // Menangani khusus masalah koneksi
      debugPrint('ApiService: Network error (SocketException): ${e.message}');
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda.',
      );
    } on TimeoutException catch (e) {
      // Menangani khusus timeout
      debugPrint('ApiService: Request timed out (TimeoutException): $e');
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      debugPrint('ApiService: Terjadi pengecualian selama panggilan API: $e');
      rethrow;
    }
  }
}
