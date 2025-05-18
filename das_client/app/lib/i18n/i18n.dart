import 'package:app/i18n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

export 'package:app/i18n/gen/app_localizations.dart';
export 'package:app/i18n/src/build_context_x.dart';

const localizationDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const supportedLocales = [
  Locale('de', 'CH'),
  Locale('fr', 'CH'),
  Locale('it', 'CH'),
  Locale('en'),
];

Locale defaultLocale(Locale? locale, Iterable<Locale> supported) {
  for (final supportedLocale in supported) {
    if (supportedLocale.languageCode == locale?.languageCode) {
      return supportedLocale;
    }
  }

  return supportedLocales.first;
}
