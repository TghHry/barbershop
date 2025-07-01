// import 'dart:convert';
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
        // --- SOLUSI: Pastikan semua properti int diparsing dengan aman ---
        // Ini akan menangani kasus di mana backend mengirimkan angka sebagai string.
        id: json['id'] is int
            ? json['id'] as int
            : int.parse(json['id'].toString()),
        userId: json['user_id'] is int
            ? json['user_id'] as int
            : int.parse(json['user_id'].toString()),
        serviceId: json['service_id'] is int
            ? json['service_id'] as int
            : int.parse(json['service_id'].toString()),
        // --- Akhir Solusi ---
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
