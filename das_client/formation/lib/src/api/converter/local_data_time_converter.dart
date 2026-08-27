import 'package:json_annotation/json_annotation.dart';

class const LocalDataTimeConverter() implements JsonConverter<DateTime, String> {
  @override
  DateTime fromJson(String date) => DateTime.parse(date).toLocal();

  @override
  String toJson(DateTime date) => date.toIso8601String();
}
