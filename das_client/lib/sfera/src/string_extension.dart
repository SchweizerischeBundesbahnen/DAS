extension XmlNullableStringExtension on String? {
  String? get unescapedString {
    return this?.unescapedString ?? this;
  }
}

extension XmlStringExtension on String {
  String get unescapedString {
    return replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&apos;', "'")
        .replaceAll('&quot;', '"');
  }
}
