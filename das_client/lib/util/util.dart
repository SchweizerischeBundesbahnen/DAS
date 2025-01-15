class Util {
  static int? tryParseInt(String? value) {
    return value != null ? int.tryParse(value) : null;
  }

  static double? tryParseDouble(String? value) {
    return value != null ? double.tryParse(value) : null;
  }
}
