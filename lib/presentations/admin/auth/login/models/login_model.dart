import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint

// Model for the 'user' object
class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt; // It's nullable as it can be 'null'
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint('User.fromJson: Parsing user data: $json'); // Debug print input JSON
    try {
      return User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        emailVerifiedAt: json['email_verified_at'] != null
            ? DateTime.parse(json['email_verified_at'] as String)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    } catch (e) {
      debugPrint('User.fromJson: Error parsing user data: $e'); // Debug print parsing errors
      rethrow; // Re-throw the error so it can be caught higher up
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('User.toJson: Converting user object to JSON...'); // Debug print conversion start
    final Map<String, dynamic> jsonMap = {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    debugPrint('User.toJson: Output JSON: $jsonMap'); // Debug print output JSON
    return jsonMap;
  }
}

// Model for the 'data' object
class LoginData {
  final String token;
  final User user;

  LoginData({
    required this.token,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    debugPrint('LoginData.fromJson: Parsing login data: $json'); // Debug print input JSON
    try {
      return LoginData(
        token: json['token'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>), // Recursive call, User prints will show
      );
    } catch (e) {
      debugPrint('LoginData.fromJson: Error parsing login data: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('LoginData.toJson: Converting login data object to JSON...');
    final Map<String, dynamic> jsonMap = {
      'token': token,
      'user': user.toJson(),
    };
    debugPrint('LoginData.toJson: Output JSON: $jsonMap');
    return jsonMap;
  }
}

// Model for the overall response
class LoginResponse {
  final String message;
  final LoginData data;

  LoginResponse({
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('LoginResponse.fromJson: Parsing overall response: $json'); // Debug print input JSON
    try {
      return LoginResponse(
        message: json['message'] as String,
        data: LoginData.fromJson(json['data'] as Map<String, dynamic>), // Recursive call, LoginData prints will show
      );
    } catch (e) {
      debugPrint('LoginResponse.fromJson: Error parsing overall response: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('LoginResponse.toJson: Converting overall response object to JSON...');
    final Map<String, dynamic> jsonMap = {
      'message': message,
      'data': data.toJson(),
    };
    debugPrint('LoginResponse.toJson: Output JSON: $jsonMap');
    return jsonMap;
  }
}

// --- Example Usage (for testing) ---
void main() {
  final String jsonString = """
  {
      "message": "Login berhasil",
      "data": {
          "token": "2|cAahbgB3kvVvlyb7mBYbFiD91dfP1ovsK1kviBC4e095849e",
          "user": {
              "id": 2,
              "name": "Budi",
              "email": "budi@mail.com",
              "email_verified_at": null,
              "created_at": "2025-06-19T07:22:40.000000Z",
              "updated_at": "2025-06-19T07:22:40.000000Z"
          }
      }
  }
  """;

  debugPrint('--- Starting JSON Parsing Debug ---');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  debugPrint('Main: Decoded raw JSON map: $jsonMap');

  try {
    final LoginResponse response = LoginResponse.fromJson(jsonMap);

    debugPrint('--- Parsing Successful! ---');
    debugPrint('Final Parsed Message: ${response.message}');
    debugPrint('Final Parsed Token: ${response.data.token}');
    debugPrint('Final Parsed User ID: ${response.data.user.id}');
    debugPrint('Final Parsed User Name: ${response.data.user.name}');
    debugPrint('Final Parsed User Email: ${response.data.user.email}');
    debugPrint('Final Parsed Email Verified At: ${response.data.user.emailVerifiedAt}');
    debugPrint('Final Parsed User Created At: ${response.data.user.createdAt}');
    debugPrint('Final Parsed User Updated At: ${response.data.user.updatedAt}');

    // Demonstrate toJson debugging
    debugPrint('--- Testing toJson Debug ---');
    final Map<String, dynamic> convertedJson = response.toJson();
    debugPrint('Main: Converted object back to JSON map: $convertedJson');

  } catch (e) {
    debugPrint('--- Parsing Failed! ---');
    debugPrint('Error during parsing: $e');
  }
  debugPrint('--- End JSON Parsing Debug ---');
}