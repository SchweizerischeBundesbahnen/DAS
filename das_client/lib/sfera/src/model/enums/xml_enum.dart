
abstract interface class XmlEnum {
  String get xmlValue;

  static T? valueOf<T extends XmlEnum>(List<T> allValues, String? xmlValue) {
    return allValues.where((it) => it.xmlValue == xmlValue).firstOrNull;
  }
}
