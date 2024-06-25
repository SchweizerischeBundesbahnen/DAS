import 'package:das_client/i18n/i18n.dart';
import 'package:flutter/widgets.dart';

extension BuildContextX on BuildContext {
  /// The localized strings.
  AppLocalizations get l10n {
    return AppLocalizations.of(this)!;
  }
}