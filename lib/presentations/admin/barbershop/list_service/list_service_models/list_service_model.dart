import 'dart:convert';

// Model for a single 'service' item within the data list
class ServiceItem {
  final int id;
  final String name;
  final String description;
  final String price; // Keeping as String as per JSON, but could be double if parsed
  final DateTime createdAt;
  final DateTime updatedAt;
  final String employeeName;
  final String employeePhoto;
  final String servicePhoto;
  final String employeePhotoUrl;
  final String servicePhotoUrl;

  ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.employeeName,
    required this.employeePhoto,
    required this.servicePhoto,
    required this.employeePhotoUrl,
    required this.servicePhotoUrl,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      employeeName: json['employee_name'] as String,
      employeePhoto: json['employee_photo'] as String,
      servicePhoto: json['service_photo'] as String,
      employeePhotoUrl: json['employee_photo_url'] as String,
      servicePhotoUrl: json['service_photo_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'employee_name': employeeName,
      'employee_photo': employeePhoto,
      'service_photo': servicePhoto,
      'employee_photo_url': employeePhotoUrl,
      'service_photo_url': servicePhotoUrl,
    };
  }
}

// Model for the overall response containing the list of services
class ServiceListResponse {
  final String message;
  final List<ServiceItem> data; // List of ServiceItem objects

  ServiceListResponse({
    required this.message,
    required this.data,
  });

  factory ServiceListResponse.fromJson(Map<String, dynamic> json) {
    // Cast the 'data' list to a List<dynamic> and then map each item
    var list = json['data'] as List;
    List<ServiceItem> serviceList = list.map((i) => ServiceItem.fromJson(i)).toList();

    return ServiceListResponse(
      message: json['message'] as String,
      data: serviceList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

// --- Example Usage (for testing) ---
void main() {
  final String jsonString = """
  {
      "message": "List layanan berhasil diambil",
      "data": [
          {
              "id": 1,
              "name": "Cukur Jenggot",
              "description": "Cukur rapi profesional",
              "price": "40000.00",
              "created_at": "2025-06-25T04:58:19.000000Z",
              "updated_at": "2025-06-25T04:58:19.000000Z",
              "employee_name": "Pak Budi",
              "employee_photo": "photos/employee_gseSZdGxng.jpg",
              "service_photo": "photos/service_5GiwMLt1qk.jpg",
              "employee_photo_url": "https://appsalon.mobileprojp.com/public/photos/employee_gseSZdGxng.jpg",
              "service_photo_url": "https://appsalon.mobileprojp.com/public/photos/service_5GiwMLt1qk.jpg"
          },
          {
              "id": 3,
              "name": "potong kaki",
              "description": "dswafdasdf",
              "price": "1200000.00",
              "created_at": "2025-06-25T07:18:50.000000Z",
              "updated_at": "2025-06-25T07:18:50.000000Z",
              "employee_name": "ASEp",
              "employee_photo": "photos/employee_YpRPJH0BId.jpg",
              "service_photo": "photos/service_KRjfpCYfH8.jpg",
              "employee_photo_url": "https://appsalon.mobileprojp.com/public/photos/employee_YpRPJH0BId.jpg",
              "service_photo_url": "https://appsalon.mobileprojp.com/public/photos/service_KRjfpCYfH8.jpg"
          }
      ]
  }
  """;

  final Map<String, dynamic> jsonMap = json.decode(jsonString);

  final ServiceListResponse response = ServiceListResponse.fromJson(jsonMap);

  print('Message: ${response.message}');
  print('Number of services: ${response.data.length}');
  if (response.data.isNotEmpty) {
    print('First service name: ${response.data[0].name}');
    print('First service price: ${response.data[0].price}');
    print('First service employee: ${response.data[0].employeeName}');
    print('First service photo URL: ${response.data[0].servicePhotoUrl}');
  }
}