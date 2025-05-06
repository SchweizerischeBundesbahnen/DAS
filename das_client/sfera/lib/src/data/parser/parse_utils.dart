class ParseUtils {
  static int? tryParseInt(String? value) {
    return value != null ? int.tryParse(value) : null;
  }

  static double? tryParseDouble(String? value) {
    return value != null ? double.tryParse(value) : null;
  }

  static DateTime? tryParseDateTime(String? value) {
    return value != null ? DateTime.tryParse(value) : null;
  }

  static bool? tryParseBool(String? value) {
    return value != null ? bool.tryParse(value) : null;
  }
}
