import 'dart:convert';
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/booking/models/booking_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/delete/models/delete_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/update/models/update_models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For securely getting the token
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException

// Import your BookingResponse model (for create)
// import 'package:barbershop2/models/booking_models/booking_response.dart';
// // Import your UpdateBookingResponse model (for update)
// import 'package:barbershop2/models/booking_models/update_booking_response.dart';
// // Import your DeleteBookingResponse model (for delete)
// import 'package:barbershop2/models/booking_models/delete_booking_response.dart'; // Make sure this import is correct

// Define your base URL
const String baseUrl =
    'https://appsalon.mobileprojp.com'; // Your actual base URL

class BookingService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Method to create a new booking (existing)
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
      final requestBody = json.encode({
        'user_id': userId,
        'service_id': serviceId,
        'booking_time': bookingTime.toIso8601String(),
      });
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final BookingResponse bookingResponse = BookingResponse.fromJson(
          responseData,
        );
        return bookingResponse;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Unauthorized. Your session may have expired. Please log in again.',
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Failed to create booking.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}';
          });
        }
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // No internet connection
      debugPrint(
        'BookingService: Network error (SocketException): ${e.message}',
      );
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda: ${e.message}',
      ); // <-- Use e.message here
    } on TimeoutException catch (e) {
      // Request timed out
      debugPrint('BookingService: Request timed out (TimeoutException): $e');
      throw Exception(
        'Permintaan ke server habis waktu. Coba lagi: ${e.toString()}',
      ); // <-- Use e.toString() here
    } catch (e) {
      // Any other unexpected errors
      debugPrint('BookingService: An unexpected error occurred: $e');
      throw Exception(
        'Terjadi kesalahan tidak terduga: ${e.toString()}',
      ); // <-- Use e.toString() here
    }
  }

  // Method to update an existing booking (existing)
  Future<UpdateBookingResponse> updateBooking({
    required int bookingId,
    String? status,
    DateTime? bookingTime,
  }) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId');
    debugPrint('BookingService: Attempting to update booking ID: $bookingId');
    try {
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint(
          'BookingService: Authentication token not found. Cannot update booking.',
        );
        throw Exception('Authentication token not found. Please log in.');
      }
      final Map<String, dynamic> requestBodyMap = {};
      if (status != null) {
        requestBodyMap['status'] = status;
      }
      if (bookingTime != null) {
        requestBodyMap['booking_time'] = bookingTime.toIso8601String();
      }
      final requestBody = json.encode(requestBodyMap);
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final UpdateBookingResponse updateResponse =
            UpdateBookingResponse.fromJson(responseData);
        return updateResponse;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Unauthorized. Your session may have expired. Please log in again.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('Booking with ID $bookingId not found.');
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ?? 'Failed to update booking.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}';
          });
        }
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      // No internet connection
      debugPrint(
        'BookingService: Network error (SocketException): ${e.message}',
      );
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda: ${e.message}',
      ); // <-- Use e.message here
    } on TimeoutException catch (e) {
      // Request timed out
      debugPrint('BookingService: Request timed out (TimeoutException): $e');
      throw Exception(
        'Permintaan ke server habis waktu. Coba lagi: ${e.toString()}',
      ); // <-- Use e.toString() here
    } catch (e) {
      // Any other unexpected errors
      debugPrint('BookingService: An unexpected error occurred: $e');
      throw Exception(
        'Terjadi kesalahan tidak terduga: ${e.toString()}',
      ); // <-- Use e.toString() here
    }
  }

  // NEW: Method to delete an existing booking
  Future<DeleteBookingResponse> deleteBooking({required int bookingId}) async {
    final url = Uri.parse('$baseUrl/api/bookings/$bookingId');
    debugPrint('BookingService: Attempting to delete booking ID: $bookingId');
    debugPrint('BookingService: Delete URL: $url');

    try {
      // Retrieve the authentication token from secure storage
      final String? token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        debugPrint(
          'BookingService: Authentication token not found. Cannot delete booking.',
        );
        throw Exception('Authentication token not found. Please log in.');
      }

      debugPrint(
        'BookingService: Found token. Making DELETE request with Authorization header.',
      );

      final response = await http.delete(
        // Using DELETE method
        url,
        headers: {
          'Accept': 'application/json', // Request JSON response
          'Authorization': 'Bearer $token', // Include the Bearer token
        },
      );

      debugPrint(
        'BookingService: Delete Booking Response Status Code: ${response.statusCode}',
      );
      debugPrint(
        'BookingService: Delete Booking Response Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        // Successful deletion
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint(
          'BookingService: Booking deleted successfully! Parsing response...',
        );
        final DeleteBookingResponse deleteResponse =
            DeleteBookingResponse.fromJson(responseData);
        debugPrint(
          'BookingService: Parsed Delete Message: ${deleteResponse.message}',
        );
        return deleteResponse;
      } else if (response.statusCode == 401) {
        debugPrint(
          'BookingService: Unauthorized access (401) for delete booking. Token might be expired or invalid.',
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
        // Handle other API errors
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage =
            errorData['message'] ??
            'Failed to delete booking. Please try again.';
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          errorData['errors'].forEach((key, value) {
            errorMessage +=
                '\n${value[0]}'; // Assuming errors are arrays of strings
          });
        }
        debugPrint('BookingService: Delete Booking API Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      debugPrint(
        'BookingService: Network error (SocketException) during delete booking: ${e.message}',
      );
      throw Exception(
        'Tidak ada koneksi internet. Mohon periksa koneksi Anda.',
      );
    } on TimeoutException catch (e) {
      debugPrint(
        'BookingService: Request timed out (TimeoutException) during delete booking: $e',
      );
      throw Exception('Permintaan ke server habis waktu. Coba lagi.');
    } catch (e) {
      debugPrint(
        'BookingService: An unexpected error occurred during delete booking: $e',
      );
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
