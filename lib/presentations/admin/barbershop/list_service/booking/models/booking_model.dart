import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint

// Model for the 'data' object within the booking response
class BookingData {
  final int userId;
  final int serviceId;
  final DateTime bookingTime; // API sends a specific time, like "2025-06-20T14:00:00"
  final DateTime updatedAt;
  final DateTime createdAt;
  final int id;

  BookingData({
    required this.userId,
    required this.serviceId,
    required this.bookingTime,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    debugPrint('BookingData.fromJson: Parsing booking data: $json');
    try {
      return BookingData(
        userId: json['user_id'] as int,
        serviceId: json['service_id'] as int,
        // The booking_time might not have the 'Z' (UTC) suffix, so DateTime.parse works directly.
        bookingTime: DateTime.parse(json['booking_time'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        id: json['id'] as int,
      );
    } catch (e) {
      debugPrint('BookingData.fromJson: Error parsing booking data: $e in $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('BookingData.toJson: Converting booking data to JSON for ID: $id');
    final Map<String, dynamic> jsonMap = {
      'user_id': userId,
      'service_id': serviceId,
      'booking_time': bookingTime.toIso8601String(), // Convert DateTime back to ISO string
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'id': id,
    };
    debugPrint('BookingData.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}

// Model for the overall booking response
class BookingResponse {
  final String message;
  final BookingData data;

  BookingResponse({
    required this.message,
    required this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('BookingResponse.fromJson: Parsing overall booking response: $json');
    try {
      return BookingResponse(
        message: json['message'] as String,
        data: BookingData.fromJson(json['data'] as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('BookingResponse.fromJson: Error parsing overall booking response: $e in $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('BookingResponse.toJson: Converting overall booking response to JSON.');
    final Map<String, dynamic> jsonMap = {
      'message': message,
      'data': data.toJson(),
    };
    debugPrint('BookingResponse.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}

// --- Example Usage (for testing) ---
void main() {
  final String jsonString = """
  {
      "message": "Booking berhasil dibuat",
      "data": {
          "user_id": 2,
          "service_id": 1,
          "booking_time": "2025-06-20T14:00:00",
          "updated_at": "2025-06-23T08:30:07.000000Z",
          "created_at": "2025-06-23T08:30:07.000000Z",
          "id": 2
      }
  }
  """;

  debugPrint('--- Starting Booking Parsing Debug (Manual) ---');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  debugPrint('Main: Decoded raw JSON map: $jsonMap');

  try {
    final BookingResponse response = BookingResponse.fromJson(jsonMap);

    debugPrint('--- Parsing Successful! ---');
    debugPrint('Message: ${response.message}');
    debugPrint('Booking ID: ${response.data.id}');
    debugPrint('User ID: ${response.data.userId}');
    debugPrint('Service ID: ${response.data.serviceId}');
    debugPrint('Booking Time: ${response.data.bookingTime}');
    debugPrint('Created At: ${response.data.createdAt}');

    debugPrint('--- Testing toJson Debug (Manual) ---');
    final Map<String, dynamic> convertedJson = response.toJson();
    debugPrint('Main: Converted object back to JSON map: $convertedJson');

  } catch (e) {
    debugPrint('--- Parsing Failed! (Manual) ---');
    debugPrint('Error during parsing: $e');
  }
  debugPrint('--- End Booking Parsing Debug (Manual) ---');
}