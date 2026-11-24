import 'package:app/i18n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

export 'package:app/i18n/gen/app_localizations.dart';
export 'package:app/i18n/src/build_context_x.dart';

final localizationDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

const supportedLocales = [
  Locale('de', 'CH'),
  Locale('fr', 'CH'),
  Locale('it', 'CH'),
];

Locale defaultLocale(Locale? locale, Iterable<Locale> supported) {
  for (final supportedLocale in supported) {
    if (supportedLocale.languageCode == locale?.languageCode) {
      return supportedLocale;
    }
  }

  return supportedLocales.first;
}
