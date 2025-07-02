import 'package:flutter/foundation.dart'; // Untuk debugPrint

class DeleteBookingResponse {
  final String message;
  final dynamic data; // 'data' is null in your JSON, so dynamic is appropriate

  DeleteBookingResponse({
    required this.message,
    this.data, // Make it optional in constructor as it can be null
  });

  // Factory constructor untuk membuat instance dari Map JSON
  factory DeleteBookingResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('DeleteBookingResponse.fromJson: Parsing delete booking response: $json');
    try {
      return DeleteBookingResponse(
        message: json['message'] as String, // Mengambil nilai 'message' sebagai String
        data: json['data'], // Mengambil nilai 'data' apa adanya (bisa null)
      );
    } catch (e) {
      debugPrint('DeleteBookingResponse.fromJson: Error parsing delete booking response: $e in $json');
      rethrow; // Melemparkan kembali error agar bisa ditangani di layer atas
    }
  }

  // Metode untuk mengkonversi instance menjadi Map JSON (opsional, tapi sering berguna)
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