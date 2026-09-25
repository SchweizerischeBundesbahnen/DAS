import 'package:json_annotation/json_annotation.dart';

part 'user_property_model.g.dart';

@JsonSerializable()
class UserPropertyModel({
  required final DateTime? lastUpdated,
  required final String? value,
}) {
  factory UserPropertyModel.fromJson(Map<String, dynamic> json) {
    return _$UserPropertyModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserPropertyModelToJson(this);
}
