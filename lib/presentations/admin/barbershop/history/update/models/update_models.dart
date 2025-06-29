import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint

// Model for the 'data' object within the update booking response
class UpdatedBookingData {
  final int id;
  final int userId;
  final int serviceId;
  final DateTime bookingTime;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  UpdatedBookingData({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.bookingTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UpdatedBookingData.fromJson(Map<String, dynamic> json) {
    debugPrint('UpdatedBookingData.fromJson: Parsing booking data: $json');
    try {
      return UpdatedBookingData(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        serviceId: json['service_id'] as int,
        bookingTime: DateTime.parse(json['booking_time'] as String),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    } catch (e) {
      debugPrint('UpdatedBookingData.fromJson: Error parsing booking data: $e in $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('UpdatedBookingData.toJson: Converting booking data to JSON for ID: $id');
    final Map<String, dynamic> jsonMap = {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'booking_time': bookingTime.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    debugPrint('UpdatedBookingData.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}

// Model for the overall update booking response
class UpdateBookingResponse {
  final String message;
  final UpdatedBookingData data;

  UpdateBookingResponse({
    required this.message,
    required this.data,
  });

  factory UpdateBookingResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('UpdateBookingResponse.fromJson: Parsing overall update booking response: $json');
    try {
      return UpdateBookingResponse(
        message: json['message'] as String,
        data: UpdatedBookingData.fromJson(json['data'] as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('UpdateBookingResponse.fromJson: Error parsing overall update booking response: $e in $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('UpdateBookingResponse.toJson: Converting overall update booking response to JSON.');
    final Map<String, dynamic> jsonMap = {
      'message': message,
      'data': data.toJson(),
    };
    debugPrint('UpdateBookingResponse.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}


void main() {
  final String jsonString = """
  {
      "message": "Booking berhasil diperbarui",
      "data": {
          "id": 1,
          "user_id": 2,
          "service_id": 1,
          "booking_time": "2025-06-21T15:30:00",
          "status": "confirmed",
          "created_at": "2025-06-23T08:29:59.000000Z",
          "updated_at": "2025-06-23T08:32:09.000000Z"
      }
  }
  """;

  debugPrint('--- Starting Update Booking Parsing Debug (json_serializable) ---');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  debugPrint('Main: Decoded raw JSON map: $jsonMap');

  try {
    final UpdateBookingResponse response = UpdateBookingResponse.fromJson(jsonMap);

    debugPrint('--- Parsing Successful! ---');
    debugPrint('Message: ${response.message}');
    debugPrint('Updated Booking ID: ${response.data.id}');
    debugPrint('New Status: ${response.data.status}');
    debugPrint('Updated At: ${response.data.updatedAt}');

    debugPrint('--- Testing toJson Debug (json_serializable) ---');
    final Map<String, dynamic> convertedJson = response.toJson();
    debugPrint('Main: Converted object back to JSON map: $convertedJson');

  } catch (e) {
    debugPrint('--- Parsing Failed! (json_serializable) ---');
    debugPrint('Error during parsing: $e');
  }
  debugPrint('--- End Update Booking Parsing Debug (json_serializable) ---');
}