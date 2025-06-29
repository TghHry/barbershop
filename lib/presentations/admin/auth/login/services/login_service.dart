import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Required for debugPrint

// Import your LoginResponse model
// Adjust the path according to your project structure
import 'package:barbershop2/presentations/admin/auth/login/models/login_model.dart';
// If your User model is in a separate file and not implicitly imported by login_model.dart,
// you might need to import it as well:
// import 'package:barbershop2/presentations/admin/auth/login/models/user_model.dart';

// Define your base URL
const String baseUrl = 'https://appsalon.mobileprojp.com'; // IMPORTANT: Your actual base URL

class AuthService {
  // Method to handle user login
  Future<LoginResponse> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/login');
    debugPrint('AuthService: Initiating login for email: $email');
    debugPrint('AuthService: Login URL: $url');

    try {
      final requestBody = json.encode({
        'email': email,
        'password': password,
      });
      debugPrint('AuthService: Login Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // Often useful for API responses
        },
        body: requestBody,
      );

      debugPrint('AuthService: Login Response Status Code: ${response.statusCode}');
      debugPrint('AuthService: Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful login
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('AuthService: Login successful! Parsing response...');
        final LoginResponse loginResponse = LoginResponse.fromJson(responseData);
        debugPrint('AuthService: Parsed Login Token: ${loginResponse.data.token}');
        debugPrint('AuthService: Parsed Login User Name: ${loginResponse.data.user.name}');
        return loginResponse;
      } else {
        // Handle API errors (e.g., invalid credentials, server errors)
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Login failed. Please try again.';
        debugPrint('AuthService: API Login Error Message: $errorMessage');

        // You might want to parse specific error messages if your API returns them
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          debugPrint('AuthService: Specific Login Validation Errors found.');
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}'; // Assuming errors are arrays of strings
            debugPrint('  Login Error Field: $key, Message: ${value[0]}');
          });
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      // Network-related errors (e.g., no internet connection)
      debugPrint('AuthService: Network Error during login: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Any other unexpected errors
      debugPrint('AuthService: Unexpected Error during login: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

