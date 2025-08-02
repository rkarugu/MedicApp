import 'package:json_annotation/json_annotation.dart';

import 'medical_worker.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;

  const LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginData {
  @JsonKey(name: 'medical_worker')
  final MedicalWorker medicalWorker;
  final String token;
  @JsonKey(name: 'token_type')
  final String tokenType;

  const LoginData({
    required this.medicalWorker,
    required this.token,
    required this.tokenType,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => _$LoginDataFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}
