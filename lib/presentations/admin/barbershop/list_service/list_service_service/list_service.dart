import 'dart:convert';
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For securely getting the token

// Import your ServiceListResponse model
// Adjust the path according to your project structure
import 'package:barbershop2/presentations/admin/barbershop/list_service/list_service_models/list_service_model.dart'; // Make sure this import is correct

// Define your base URL
const String baseUrl =
    'https://appsalon.mobileprojp.com'; // Your actual base URL

class ServiceService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Method to fetch the list of services
  Future<ServiceListResponse> getServices() async {
    final url = Uri.parse('$baseUrl/api/services');
    debugPrint('ServiceService: Attempting to fetch services from URL: $url');

    try {
      // Retrieve the authentication token from secure storage
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint(
          'ServiceService: Authentication token not found. Cannot fetch services.',
        );
        throw Exception('Authentication token not found. Please log in.');
      }

      debugPrint(
        'ServiceService: Found token. Making GET request with Authorization header.',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Include the Bearer token
        },
      );

      debugPrint(
        'ServiceService: Response Status Code: ${response.statusCode}',
      );
      debugPrint('ServiceService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful response
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint(
          'ServiceService: Services fetched successfully! Parsing response...',
        );
        final ServiceListResponse serviceResponse =
            ServiceListResponse.fromJson(responseData);
        debugPrint(
          'ServiceService: Parsed ${serviceResponse.data.length} services.',
        );
        return serviceResponse;
      } else if (response.statusCode == 401) {
        // Unauthorized - token might be expired or invalid
        debugPrint(
          'ServiceService: Unauthorized access (401). Token might be expired or invalid.',
        );
        throw Exception(
          'Unauthorized. Your session may have expired. Please log in again.',
        );
      } else {
        // Handle other API errors
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ??
            'Failed to fetch services. Please try again.';
        debugPrint('ServiceService: API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // No internet connection
      debugPrint(
        'ServiceService: Network error (SocketException): ${e.message}',
      );
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda.',
      );
    } on TimeoutException catch (e) {
      // Request timed out
      debugPrint('ServiceService: Request timed out (TimeoutException): $e');
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      // Any other unexpected errors
      debugPrint('ServiceService: An unexpected error occurred: $e');
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
