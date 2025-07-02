import 'package:flutter/foundation.dart'; // Untuk debugPrint

// import 'package:flutter/foundation.dart'; // Untuk debugPrint

class ServiceItem {
  final int? id;
  final String? name;
  final String? description;
  final double? price; // Menggunakan double? untuk harga desimal
  final String? employeeName;
  final String? employeePhoto;
  final String? servicePhoto;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? employeePhotoUrl;
  final String? servicePhotoUrl;

  ServiceItem({
    this.id,
    this.name,
    this.description,
    this.price,
    this.employeeName,
    this.employeePhoto,
    this.servicePhoto,
    this.createdAt,
    this.updatedAt,
    this.employeePhotoUrl,
    this.servicePhotoUrl,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    debugPrint('ServiceItem.fromJson: Parsing JSON for ServiceItem: $json');

    // --- Solusi untuk masalah 'price' ---
    double? parsedPrice;
    final dynamic priceValue = json['price']; // Ambil nilai mentah dari JSON

    if (priceValue != null) {
      if (priceValue is num) {
        parsedPrice =
            priceValue.toDouble(); // Jika sudah num, konversi ke double
      } else if (priceValue is String) {
        parsedPrice = double.tryParse(
          priceValue,
        ); // Jika string, coba parse ke double
        // Opsional: Anda bisa tambahkan penanganan jika parse gagal (misal, log error)
        if (parsedPrice == null) {
          debugPrint(
            'ServiceItem.fromJson: WARNING: Could not parse price String "$priceValue" to double.',
          );
        }
      }
    }
    // --- Akhir solusi 'price' ---

    try {
      return ServiceItem(
        id: json['id'] as int?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        price: parsedPrice, // Gunakan nilai yang sudah diparsing
        employeeName: json['employee_name'] as String?,
        employeePhoto: json['employee_photo'] as String?,
        servicePhoto: json['service_photo'] as String?,
        createdAt:
            json['created_at'] != null
                ? DateTime.parse(json['created_at'] as String)
                : null,
        updatedAt:
            json['updated_at'] != null
                ? DateTime.parse(json['updated_at'] as String)
                : null,
        employeePhotoUrl: json['employee_photo_url'] as String?,
        servicePhotoUrl: json['service_photo_url'] as String?,
      );
    } catch (e) {
      debugPrint(
        'ServiceItem.fromJson: Error parsing ServiceItem: $e in $json',
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'employee_name': employeeName,
      'employee_photo': employeePhoto,
      'service_photo': servicePhoto,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'employee_photo_url': employeePhotoUrl,
      'service_photo_url': servicePhotoUrl,
    };
  }
}

class ServiceListResponse {
  final String? message;
  final List<ServiceItem> data; // Daftar objek ServiceItem

  ServiceListResponse({this.message, required this.data});

  factory ServiceListResponse.fromJson(Map<String, dynamic> json) {
    debugPrint(
      'ServiceListResponse.fromJson: Parsing JSON for ServiceListResponse: $json',
    );
    try {
      // Pastikan 'data' adalah list, jika tidak, berikan list kosong
      final List<dynamic> dataList = json['data'] as List<dynamic>? ?? [];

      return ServiceListResponse(
        message: json['message'] as String?,
        data:
            dataList
                .map(
                  (itemJson) =>
                      ServiceItem.fromJson(itemJson as Map<String, dynamic>),
                )
                .toList(),
      );
    } catch (e) {
      debugPrint(
        'ServiceListResponse.fromJson: Error parsing ServiceListResponse: $e in $json',
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
