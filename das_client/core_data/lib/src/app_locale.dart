import 'dart:io';

class AppLocale._() {
  static String resolvedLocale() {
    final localeName = Platform.localeName;

    if (localeName.startsWith('fr')) {
      return 'FR';
    } else if (localeName.startsWith('it')) {
      return 'IT';
    } else {
      return 'DE';
    }
  }
}
