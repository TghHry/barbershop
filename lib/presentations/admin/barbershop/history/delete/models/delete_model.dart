// import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint

class DeleteBookingResponse {
  final String message;
  final dynamic data; // 'data' is null in your JSON

  DeleteBookingResponse({
    required this.message,
    this.data, // Make it optional in constructor
  });

  factory DeleteBookingResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('DeleteBookingResponse.fromJson: Parsing delete booking response: $json');
    try {
      return DeleteBookingResponse(
        message: json['message'] as String,
        data: json['data'], // Will be null if it's null in JSON
      );
    } catch (e) {
      debugPrint('DeleteBookingResponse.fromJson: Error parsing delete booking response: $e in $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('DeleteBookingResponse.toJson: Converting delete booking response to JSON.');
    final Map<String, dynamic> jsonMap = {
      'message': message,
      'data': data,
    };
    debugPrint('DeleteBookingResponse.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}