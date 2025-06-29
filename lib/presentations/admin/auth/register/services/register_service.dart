import 'dart:convert';
import 'package:http/http.dart' as http;
// Import your generated models
import 'package:barbershop2/presentations/admin/auth/register/models/register_model.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

// Define your base URL
const String baseUrl = 'https://appsalon.mobileprojp.com'; // Your actual base URL

class AuthService {
  // Method to handle user registration
  Future<RegistrationResponse> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/api/register');
    debugPrint('AuthService: Registering user...');
    debugPrint('AuthService: URL: $url');
    debugPrint('AuthService: Name: $name, Email: $email');

    try {
      final requestBody = json.encode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      debugPrint('AuthService: Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('AuthService: Response Status Code: ${response.statusCode}');
      debugPrint('AuthService: Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful registration
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('AuthService: Registration successful! Parsing response...');
        final RegistrationResponse registrationResponse = RegistrationResponse.fromJson(responseData);
        debugPrint('AuthService: Parsed Token: ${registrationResponse.data.token}');
        debugPrint('AuthService: Parsed User Name: ${registrationResponse.data.user.name}');
        return registrationResponse;
      } else {
        // Handle API errors (e.g., validation errors, server errors)
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Registration failed. Please try again.';
        debugPrint('AuthService: API Error Message: $errorMessage');

        // You might want to parse specific error messages if your API returns them
        if (errorData.containsKey('errors') && errorData['errors'] is Map) {
          debugPrint('AuthService: Specific Validation Errors found.');
          errorData['errors'].forEach((key, value) {
            errorMessage += '\n${value[0]}'; // Assuming errors are arrays of strings
            debugPrint('  Error Field: $key, Message: ${value[0]}');
          });
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      // Network-related errors (e.g., no internet connection)
      debugPrint('AuthService: Network Error: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      // Any other unexpected errors
      debugPrint('AuthService: Unexpected Error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}