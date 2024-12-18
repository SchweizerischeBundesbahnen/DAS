class Util {
  static int? tryParseInt(String? value) {
    return value != null ? int.tryParse(value) : null;
  }
}
