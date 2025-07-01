import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For securely getting the token
import 'dart:io';   // For SocketException
import 'dart:async'; // For TimeoutException

// Import your BookingHistoryResponse model
// Adjust the path according to your project structure
import 'package:barbershop2/presentations/admin/barbershop/home/history/history_models/history_model.dart';

// Define your base URL (make sure it's consistent across your services)
const String baseUrl = 'https://appsalon.mobileprojp.com'; // Your actual base URL

class BookingHistoryService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Method to fetch the list of a user's booking history
  Future<BookingHistoryResponse> getBookingHistory() async {
    final url = Uri.parse('$baseUrl/api/bookings');
    debugPrint('BookingHistoryService: Attempting to fetch booking history from URL: $url');

    try {
      // Retrieve the authentication token from secure storage
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint('BookingHistoryService: Authentication token not found. Cannot fetch booking history.');
        throw Exception('Authentication token not found. Please log in.');
      }

      debugPrint('BookingHistoryService: Found token. Making GET request with Authorization header.');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Include the Bearer token
        },
      );

      debugPrint('BookingHistoryService: Response Status Code: ${response.statusCode}');
      debugPrint('BookingHistoryService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful response
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('BookingHistoryService: Booking history fetched successfully! Parsing response...');
        final BookingHistoryResponse historyResponse = BookingHistoryResponse.fromJson(responseData);
        debugPrint('BookingHistoryService: Parsed ${historyResponse.data.length} booking records.');
        return historyResponse;
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be expired or invalid
        debugPrint('BookingHistoryService: Unauthorized access (401). Token might be expired or invalid.');
        throw Exception('Unauthorized. Your session may have expired. Please log in again.');
      }
      else {
        // Handle other API errors
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Failed to fetch booking history. Please try again.';
        debugPrint('BookingHistoryService: API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // No internet connection
      debugPrint('BookingHistoryService: Network error (SocketException): ${e.message}');
      throw Exception('Tidak ada koneksi internet. Mohon periksa koneksi Anda.');
    } on TimeoutException catch (e) {
      // Request timed out
      debugPrint('BookingHistoryService: Request timed out (TimeoutException): $e');
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      // Any other unexpected errors
      debugPrint('BookingHistoryService: An unexpected error occurred: $e');
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}

