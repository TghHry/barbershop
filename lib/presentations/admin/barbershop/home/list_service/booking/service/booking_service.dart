import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For securely getting the token
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException

// Import your BookingResponse model (for create)
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/booking/models/booking_model.dart';
// Import your UpdateBookingResponse model (for update)
import 'package:barbershop2/presentations/admin/barbershop/home/history/update/models/update_models.dart'; // Make sure this import is correct

// Define your base URL
const String baseUrl =
    'https://appsalon.mobileprojp.com'; // Your actual base URL

class BookingService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Method to create a new booking (This should already be in your file)
  Future<BookingResponse> createBooking({
    required int userId,
    required int serviceId,
    required DateTime bookingTime,
  }) async {
    final url = Uri.parse('$baseUrl/api/bookings');
    debugPrint('BookingService: Attempting to create booking...');
    try {
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint(
          'BookingService: Authentication token not found. Cannot create booking.',
        );
        throw Exception('Authentication token not found. Please log in.');
      }

      debugPrint(
        'BookingService: Found token. Making POST request with Authorization header.',
      );

      final requestBody = json.encode({
        'user_id': userId,
        'service_id': serviceId,
        'booking_time': bookingTime.toIso8601String(),
      });
      debugPrint('BookingService: Create Booking Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      debugPrint(
        'BookingService: Create Booking Response Status Code: ${response.statusCode}',
      );
      debugPrint(
        'BookingService: Create Booking Response Body: ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint(
          'BookingService: Booking created successfully! Parsing response...',
        );
        final BookingResponse bookingResponse = BookingResponse.fromJson(
          responseData,
        );
        return bookingResponse;
      } else if (response.statusCode == 401) {
        debugPrint(
          'BookingService: Unauthorized access (401) for create booking. Token might be expired or invalid.',
        );
        throw Exception(
          'Unauthorized. Your session may have expired. Please log in again.',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ??
            'Failed to create booking. Please try again.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}';
          });
        }
        debugPrint('BookingService: Create Booking API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      debugPrint(
        'BookingService: Network error (SocketException) during create booking: ${e.message}',
      );
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda.',
      );
    } on TimeoutException catch (e) {
      debugPrint(
        'BookingService: Request timed out (TimeoutException) during create booking: $e',
      );
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      debugPrint(
        'BookingService: An unexpected error occurred during create booking: $e',
      );
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // This is the 'updateBooking' method that was missing. Ensure it's present in your BookingService class.
  Future<UpdateBookingResponse> updateBooking({
    required int bookingId,
    String? status, // Optional: if you want to update status
    DateTime? bookingTime, // Optional: if you want to update booking time
    // Add other fields you might want to update here
  }) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId');
    debugPrint('BookingService: Attempting to update booking ID: $bookingId');
    debugPrint('BookingService: Update URL: $url');

    try {
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint(
          'BookingService: Authentication token not found. Cannot update booking.',
        );
        throw Exception('Authentication token not found. Please log in.');
      }

      debugPrint(
        'BookingService: Found token. Making PATCH request with Authorization header.',
      );

      final Map<String, dynamic> requestBodyMap = {};
      if (status != null) {
        requestBodyMap['status'] = status;
      }
      if (bookingTime != null) {
        requestBodyMap['booking_time'] = bookingTime.toIso8601String();
      }
      // Add other fields here as needed:
      // if (newServiceId != null) {
      //   requestBodyMap['service_id'] = newServiceId;
      // }

      final requestBody = json.encode(requestBodyMap);
      debugPrint('BookingService: Update Booking Request Body: $requestBody');

      final response = await http.patch(
        // Using PATCH for partial updates
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      debugPrint(
        'BookingService: Update Booking Response Status Code: ${response.statusCode}',
      );
      debugPrint(
        'BookingService: Update Booking Response Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint(
          'BookingService: Booking updated successfully! Parsing response...',
        );
        final UpdateBookingResponse updateResponse =
            UpdateBookingResponse.fromJson(responseData);
        return updateResponse;
      } else if (response.statusCode == 401) {
        debugPrint(
          'BookingService: Unauthorized access (401) for update booking. Token might be expired or invalid.',
        );
        throw Exception(
          'Unauthorized. Your session may have expired. Please log in again.',
        );
      } else if (response.statusCode == 404) {
        debugPrint(
          'BookingService: Booking not found (404) for ID: $bookingId.',
        );
        throw Exception('Booking with ID $bookingId not found.');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ??
            'Failed to update booking. Please try again.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}';
          });
        }
        debugPrint('BookingService: Update Booking API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      debugPrint(
        'BookingService: Network error (SocketException) during update booking: ${e.message}',
      );
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda.',
      );
    } on TimeoutException catch (e) {
      debugPrint(
        'BookingService: Request timed out (TimeoutException) during update booking: $e',
      );
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      debugPrint(
        'BookingService: An unexpected error occurred during update booking: $e',
      );
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
