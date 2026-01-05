import 'package:json_annotation/json_annotation.dart';

class LocalDataTimeConverter implements JsonConverter<DateTime, String> {
  const LocalDataTimeConverter();

  @override
  DateTime fromJson(String date) {
    return DateTime.parse(date).toLocal();
  }

  @override
  String toJson(DateTime date) => date.toIso8601String();
}
