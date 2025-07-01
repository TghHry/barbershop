// import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint

// Nested model for the 'service' object within each booking item
class BookedService {
  final int id;
  final String name;
  final String description;
  final String price;
  final DateTime? createdAt; // Can be null
  final DateTime? updatedAt; // Can be null

  BookedService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory BookedService.fromJson(Map<String, dynamic> json) {
    debugPrint('BookedService.fromJson: Parsing service data: $json');
    try {
      // Use int.tryParse for IDs that might come as strings.
      // And handle potentially missing nullable DateTime fields
      return BookedService(
        id: int.tryParse(json['id'].toString()) ?? 0, // Safer parsing for int
        name: json['name'] as String,
        description: json['description'] as String,
        price: json['price'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
    } catch (e) {
      debugPrint(
        'BookedService.fromJson: Error parsing service data: $e in $json',
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint(
      'BookedService.toJson: Converting service object to JSON for ID: $id',
    );
    final Map<String, dynamic> jsonMap = {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
    debugPrint('BookedService.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}

// Model for a single 'booking history' item within the data list
class BookingHistoryItem {
  final int id;
  final int userId;
  final int serviceId;
  final DateTime
  bookingTime; // "2025-06-20 14:00:00" - no 'Z' suffix, space instead of 'T'
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BookedService service; // Nested service object

  BookingHistoryItem({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.bookingTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
  });

  // --- THE CRUCIAL PART IS HERE: ENSURE ALL REQUIRED ARGUMENTS ARE PASSED ---
  factory BookingHistoryItem.fromJson(Map<String, dynamic> json) {
    debugPrint(
      'BookingHistoryItem.fromJson: Parsing booking history item: $json',
    );
    try {
      return BookingHistoryItem(
        // Safely parse IDs, assuming they could be string or int
        id: int.tryParse(json['id'].toString()) ?? 0,
        userId: int.tryParse(json['user_id'].toString()) ?? 0,
        serviceId: int.tryParse(json['service_id'].toString()) ?? 0,
        // Handling 'booking_time' format: replace space with 'T' and add 'Z' for parse
        bookingTime: DateTime.parse(
          json['booking_time'].toString().replaceFirst(' ', 'T') + 'Z',
        ),
        status:
            json['status']
                as String, // Cast directly, assuming it's always a String
        createdAt: DateTime.parse(
          json['created_at'] as String,
        ), // Parse DateTime
        updatedAt: DateTime.parse(
          json['updated_at'] as String,
        ), // Parse DateTime
        service: BookedService.fromJson(
          json['service'] as Map<String, dynamic>,
        ), // Parse nested service
      );
    } catch (e) {
      debugPrint(
        'BookingHistoryItem.fromJson: Error parsing booking history item: $e in $json',
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint(
      'BookingHistoryItem.toJson: Converting booking history item to JSON for ID: $id',
    );
    final Map<String, dynamic> jsonMap = {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      // For toJson, format booking_time back to "YYYY-MM-DD HH:MM:SS"
      'booking_time': bookingTime
          .toIso8601String()
          .replaceFirst('T', ' ')
          .replaceFirst('.000Z', ''),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'service': service.toJson(),
    };
    debugPrint('BookingHistoryItem.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}

// Model for the overall Booking History Response
class BookingHistoryResponse {
  final String message;
  final List<BookingHistoryItem> data;

  BookingHistoryResponse({required this.message, required this.data});

  factory BookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    debugPrint(
      'BookingHistoryResponse.fromJson: Parsing overall booking history response: $json',
    );
    try {
      // Ensure 'data' is treated as a List<dynamic> before mapping
      var list = json['data'] as List;
      List<BookingHistoryItem> bookingList = list
          .map((i) => BookingHistoryItem.fromJson(i as Map<String, dynamic>))
          .toList(); // Explicitly cast i to Map<String, dynamic>

      return BookingHistoryResponse(
        message: json['message'] as String,
        data: bookingList,
      );
    } catch (e) {
      debugPrint(
        'BookingHistoryResponse.fromJson: Error parsing overall booking history response: $e in $json',
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint(
      'BookingHistoryResponse.toJson: Converting overall booking history response to JSON.',
    );
    final Map<String, dynamic> jsonMap = {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
    debugPrint('BookingHistoryResponse.toJson: Generated JSON: $jsonMap');
    return jsonMap;
  }
}
