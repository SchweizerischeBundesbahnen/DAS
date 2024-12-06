import 'dart:io';

class LocalizedString {
  LocalizedString({
    this.de,
    this.fr,
    this.it,
  });

  late String? de;
  late String? fr;
  late String? it;

  String get localized {
    final localeName = Platform.localeName;
    if (localeName.startsWith('fr') && fr != null) {
      return fr!;
    } else if (localeName.startsWith('it') && it != null) {
      return it!;
    } else if (localeName.startsWith('de') && de != null) {
      return de!;
    } else {
      return de ?? fr ?? it ?? '<Missing translation>';
    }
  }

  @override
  String toString() {
    return "LocalizedString(de: '$de', fr: '$fr', it: '$it')";
  }
}
