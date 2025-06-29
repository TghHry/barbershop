import 'dart:convert';

// Model for the 'user' object
class User {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Model for the 'data' object
class RegistrationData {
  final String token;
  final User user;

  RegistrationData({
    required this.token,
    required this.user,
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

// Model for the overall response
class RegistrationResponse {
  final String message;
  final RegistrationData data;

  RegistrationResponse({
    required this.message,
    required this.data,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      message: json['message'] as String,
      data: RegistrationData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

// --- How to use these models ---
void main() {
  final String jsonString = """
  {
      "message": "Registrasi berhasil",
      "data": {
          "token": "1|2EbmBFXOcpziGQL4HSKhBeB08qr0um2XFJ1ZTaOh37ca186e",
          "user": {
              "name": "Budi",
              "email": "budi@mail.com",
              "updated_at": "2025-06-19T07:22:40.000000Z",
              "created_at": "2025-06-19T07:22:40.000000Z",
              "id": 2
          }
      }
  }
  """;

  final Map<String, dynamic> jsonMap = json.decode(jsonString);

  // Deserialize JSON to Dart object
  final RegistrationResponse response = RegistrationResponse.fromJson(jsonMap);

  print('Message: ${response.message}');
  print('Token: ${response.data.token}');
  print('User Name: ${response.data.user.name}');
  print('User Email: ${response.data.user.email}');
  print('User Created At: ${response.data.user.createdAt}');
  print('User Updated At: ${response.data.user.updatedAt}');

  // Serialize Dart object back to JSON (optional)
  final Map<String, dynamic> serializedJson = response.toJson();
  print('\nSerialized JSON: ${json.encode(serializedJson)}');
}