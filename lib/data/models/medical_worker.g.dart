// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalWorker _$MedicalWorkerFromJson(Map<String, dynamic> json) =>
    MedicalWorker(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      licenseNumber: json['license_number'] as String,
    );

Map<String, dynamic> _$MedicalWorkerToJson(MedicalWorker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'license_number': instance.licenseNumber,
    };
