// import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint

// Model untuk objek 'data' dalam respons penambahan layanan
class AddServiceData {
  final int id;
  final String name;
  final String description;
  final int price; // Perhatikan: 'price' di sini adalah int
  final String employeeName;
  final String employeePhoto;
  final String servicePhoto;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String employeePhotoUrl;
  final String servicePhotoUrl;

  AddServiceData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.employeeName,
    required this.employeePhoto,
    required this.servicePhoto,
    required this.updatedAt,
    required this.createdAt,
    required this.employeePhotoUrl,
    required this.servicePhotoUrl,
  });

  factory AddServiceData.fromJson(Map<String, dynamic> json) {
    debugPrint('AddServiceData.fromJson: Memulai parsing data layanan: $json');
    try {
      return AddServiceData(
        // --- SOLUSI: Pastikan properti int diparsing dengan aman ---
        // Ini akan menangani kasus di mana backend mengirimkan angka sebagai string.
        id: json['id'] is int
            ? json['id'] as int
            : int.parse(json['id'].toString()),
        name: json['name'] as String,
        description: json['description'] as String,
        price: json['price'] is int
            ? json['price'] as int
            : int.parse(json['price'].toString()),
        // --- Akhir Solusi ---
        employeeName: json['employee_name'] as String,
        employeePhoto: json['employee_photo'] as String,
        servicePhoto: json['service_photo'] as String,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        employeePhotoUrl: json['employee_photo_url'] as String,
        servicePhotoUrl: json['service_photo_url'] as String,
      );
    } catch (e) {
      debugPrint('AddServiceData.fromJson: Error parsing data layanan: $e di $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('AddServiceData.toJson: Mengubah objek data layanan ke JSON untuk ID: $id');
    final Map<String, dynamic> jsonMap = {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'employee_name': employeeName,
      'employee_photo': employeePhoto,
      'service_photo': servicePhoto,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'employee_photo_url': employeePhotoUrl,
      'service_photo_url': servicePhotoUrl,
    };
    debugPrint('AddServiceData.toJson: JSON yang dihasilkan: $jsonMap');
    return jsonMap;
  }
}

// Model untuk respons penambahan layanan keseluruhan
class AddServiceResponse {
  final String message;
  final AddServiceData data;

  AddServiceResponse({
    required this.message,
    required this.data,
  });

  factory AddServiceResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('AddServiceResponse.fromJson: Memulai parsing respons penambahan layanan keseluruhan: $json');
    try {
      return AddServiceResponse(
        message: json['message'] as String,
        data: AddServiceData.fromJson(json['data'] as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('AddServiceResponse.fromJson: Error parsing respons penambahan layanan keseluruhan: $e di $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint('AddServiceResponse.toJson: Mengubah respons penambahan layanan keseluruhan ke JSON.');
    final Map<String, dynamic> jsonMap = {
      'message': message,
      'data': data.toJson(),
    };
    debugPrint('AddServiceResponse.toJson: JSON yang dihasilkan: $jsonMap');
    return jsonMap;
  }
}
