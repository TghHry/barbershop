// import 'dart:convert'; // Tidak diperlukan di sini
import 'package:flutter/foundation.dart'; // For debugPrint

// Model untuk objek 'data' dalam respons penambahan layanan
class AddServiceData {
  final int id; // Jika API selalu mengirim ID non-null
  final String name; // Jika API selalu mengirim nama non-null
  final String description; // Jika API selalu mengirim deskripsi non-null
  final int price; // Perhatikan: 'price' di sini adalah int
  final String employeeName; // Jika API selalu mengirim employee_name non-null

  // >>> PERBAIKAN DI SINI <<<
  final String?
  employeePhoto; // <<< Ubah ke nullable (String?) karena API mengirim null
  // >>> AKHIR PERBAIKAN <<<

  final String servicePhoto; // Jika API selalu mengirim service_photo non-null
  final DateTime updatedAt; // Jika API selalu mengirim updatedAt non-null
  final DateTime createdAt; // Jika API selalu mengirim createdAt non-null

  // >>> PERBAIKAN DI SINI <<<
  final String? employeePhotoUrl; // <<< Tambah ini dan buat nullable (String?)
  // >>> AKHIR PERBAIKAN <<<

  final String
  servicePhotoUrl; // Jika API selalu mengirim servicePhotoUrl non-null

  AddServiceData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.employeeName,
    this.employeePhoto, // Tidak lagi 'required' jika nullable
    required this.servicePhoto,
    required this.updatedAt,
    required this.createdAt,
    this.employeePhotoUrl, // Tidak lagi 'required' jika nullable
    required this.servicePhotoUrl,
  });

  factory AddServiceData.fromJson(Map<String, dynamic> json) {
    debugPrint('AddServiceData.fromJson: Memulai parsing data layanan: $json');
    try {
      return AddServiceData(
        id:
            json['id'] is int
                ? json['id'] as int
                : int.parse(json['id'].toString()),
        name: json['name'] as String,
        description: json['description'] as String,
        price:
            json['price'] is int
                ? json['price'] as int
                : int.parse(json['price'].toString()),
        employeeName: json['employee_name'] as String,

        // >>> PERBAIKAN DI SINI <<<
        employeePhoto:
            json['employee_photo'] as String?, // <<< Gunakan 'as String?'

        // >>> AKHIR PERBAIKAN <<<
        servicePhoto: json['service_photo'] as String,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),

        // >>> PERBAIKAN DI SINI <<<
        employeePhotoUrl:
            json['employee_photo_url']
                as String?, // <<< Tambah dan gunakan 'as String?'

        // >>> AKHIR PERBAIKAN <<<
        servicePhotoUrl: json['service_photo_url'] as String,
      );
    } catch (e) {
      debugPrint(
        'AddServiceData.fromJson: Error parsing data layanan: $e di $json',
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint(
      'AddServiceData.toJson: Mengubah objek data layanan ke JSON untuk ID: $id',
    );
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
      'employee_photo_url': employeePhotoUrl, // Sertakan ini di toJson juga
      'service_photo_url': servicePhotoUrl,
    };
    debugPrint('AddServiceData.toJson: JSON yang dihasilkan: $jsonMap');
    return jsonMap;
  }
}

// Model untuk respons penambahan layanan keseluruhan
// Model ini sudah cukup baik, asalkan 'message' dan 'data' memang selalu ada
// dan tidak null dari API. Jika 'data' bisa null, maka final AddServiceData data;
// perlu diubah ke final AddServiceData? data;
class AddServiceResponse {
  final String message; // Jika API selalu mengirim message non-null
  final AddServiceData data; // Jika API selalu mengirim data non-null

  AddServiceResponse({required this.message, required this.data});

  factory AddServiceResponse.fromJson(Map<String, dynamic> json) {
    debugPrint(
      'AddServiceResponse.fromJson: Memulai parsing respons penambahan layanan keseluruhan: $json',
    );
    try {
      return AddServiceResponse(
        message: json['message'] as String,
        data: AddServiceData.fromJson(json['data'] as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint(
        'AddServiceResponse.fromJson: Error parsing respons penambahan layanan keseluruhan: $e di $json',
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    debugPrint(
      'AddServiceResponse.toJson: Mengubah respons penambahan layanan keseluruhan ke JSON.',
    );
    final Map<String, dynamic> jsonMap = {
      'message': message,
      'data': data.toJson(),
    };
    debugPrint('AddServiceResponse.toJson: JSON yang dihasilkan: $jsonMap');
    return jsonMap;
  }
}
