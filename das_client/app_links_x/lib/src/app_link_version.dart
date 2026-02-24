enum AppLinkVersion {
  v1,
  unknown
  ;

  /// Parses version in format like "v1", "v2", "v3".
  /// Returns [AppLinkVersion.unknown] if parsing fails or version unknown
  static AppLinkVersion parse(String? input) {
    if (input == null) return AppLinkVersion.unknown;

    final s = input.trim().toLowerCase();
    final match = RegExp(r'^v(\d+)$').firstMatch(s);
    if (match == null) return AppLinkVersion.unknown;

    final n = int.tryParse(match.group(1)!);
    switch (n) {
      case 1:
        return AppLinkVersion.v1;
      default:
        return AppLinkVersion.unknown;
    }
  }
}
