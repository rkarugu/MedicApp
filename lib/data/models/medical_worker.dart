import 'package:json_annotation/json_annotation.dart';

part 'medical_worker.g.dart';

@JsonSerializable()
class MedicalWorker {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'license_number')
  final String licenseNumber;

  const MedicalWorker({
    required this.id,
    required this.name,
    required this.email,
    required this.licenseNumber,
  });

  factory MedicalWorker.fromJson(Map<String, dynamic> json) => _$MedicalWorkerFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalWorkerToJson(this);
}
