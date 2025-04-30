abstract interface class XmlEnum {
  String get xmlValue;

  static T? valueOf<T extends XmlEnum>(List<T> allValues, String? xmlValue) {
    return allValues.where((it) => it.xmlValue.toLowerCase() == xmlValue?.toLowerCase()).firstOrNull;
  }

  static T valueOfOr<T extends XmlEnum>(List<T> allValues, String? xmlValue, T defaultValue) {
    return allValues.where((it) => it.xmlValue.toLowerCase() == xmlValue?.toLowerCase()).firstOrNull ?? defaultValue;
  }

  static List<String> values<T extends XmlEnum>(List<T> allValues) {
    return allValues.map((it) => it.xmlValue).toList();
  }
}
