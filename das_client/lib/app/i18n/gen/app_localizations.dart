// TODO: There is currently a problem with the format check in ci with this generated file
// TODO: This will be solved here: https://github.com/flutter/flutter/pull/167029
// TODO: Format this code before commiting

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @c_app_name.
  ///
  /// In de, this message translates to:
  /// **'DAS Client'**
  String get c_app_name;

  /// No description provided for @p_train_selection_trainnumber_description.
  ///
  /// In de, this message translates to:
  /// **'Zugnummer'**
  String get p_train_selection_trainnumber_description;

  /// No description provided for @p_train_selection_ru_description.
  ///
  /// In de, this message translates to:
  /// **'EVU'**
  String get p_train_selection_ru_description;

  /// No description provided for @p_train_selection_date_description.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get p_train_selection_date_description;

  /// No description provided for @p_train_selection_choose_date.
  ///
  /// In de, this message translates to:
  /// **'Datum wählen'**
  String get p_train_selection_choose_date;

  /// No description provided for @p_train_selection_date_not_today_warning.
  ///
  /// In de, this message translates to:
  /// **'Das gewählte Datum entspricht nicht dem aktuellen Datum.'**
  String get p_train_selection_date_not_today_warning;

  /// No description provided for @p_train_journey_header_button_dark_theme.
  ///
  /// In de, this message translates to:
  /// **'Nachtmodus'**
  String get p_train_journey_header_button_dark_theme;

  /// No description provided for @p_train_journey_header_button_light_theme.
  ///
  /// In de, this message translates to:
  /// **'Tagmodus'**
  String get p_train_journey_header_button_light_theme;

  /// No description provided for @p_train_journey_header_button_pause.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get p_train_journey_header_button_pause;

  /// No description provided for @p_train_journey_header_button_start.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get p_train_journey_header_button_start;

  /// No description provided for @p_train_journey_table_kilometre_label.
  ///
  /// In de, this message translates to:
  /// **'km'**
  String get p_train_journey_table_kilometre_label;

  /// No description provided for @p_train_journey_table_time_label.
  ///
  /// In de, this message translates to:
  /// **'an/ab'**
  String get p_train_journey_table_time_label;

  /// No description provided for @p_train_journey_table_journey_information_label.
  ///
  /// In de, this message translates to:
  /// **'Streckeninformationen'**
  String get p_train_journey_table_journey_information_label;

  /// No description provided for @p_train_journey_table_advised_speed_label.
  ///
  /// In de, this message translates to:
  /// **'FE'**
  String get p_train_journey_table_advised_speed_label;

  /// No description provided for @p_train_journey_table_graduated_speed_label.
  ///
  /// In de, this message translates to:
  /// **'OG'**
  String get p_train_journey_table_graduated_speed_label;

  /// No description provided for @p_train_journey_table_communication_network.
  ///
  /// In de, this message translates to:
  /// **'Netzart'**
  String get p_train_journey_table_communication_network;

  /// No description provided for @p_train_journey_break_series.
  ///
  /// In de, this message translates to:
  /// **'Bremsreihe'**
  String get p_train_journey_break_series;

  /// No description provided for @p_train_journey_break_series_empty.
  ///
  /// In de, this message translates to:
  /// **'Es sind keine Bremsreihen vorhanden'**
  String get p_train_journey_break_series_empty;

  /// No description provided for @p_train_journey_table_curve_type_curve.
  ///
  /// In de, this message translates to:
  /// **'Kurve'**
  String get p_train_journey_table_curve_type_curve;

  /// No description provided for @p_train_journey_table_curve_type_station_exit_curve.
  ///
  /// In de, this message translates to:
  /// **'Kurve Ausfahrt'**
  String get p_train_journey_table_curve_type_station_exit_curve;

  /// No description provided for @p_train_journey_table_curve_type_curve_after_halt.
  ///
  /// In de, this message translates to:
  /// **'Kurve nach Haltestelle'**
  String get p_train_journey_table_curve_type_curve_after_halt;

  /// No description provided for @p_train_journey_table_level_crossing.
  ///
  /// In de, this message translates to:
  /// **'BUe'**
  String get p_train_journey_table_level_crossing;

  /// No description provided for @p_train_journey_table_tram_area.
  ///
  /// In de, this message translates to:
  /// **'TS'**
  String get p_train_journey_table_tram_area;

  /// No description provided for @p_train_journey_appbar_text.
  ///
  /// In de, this message translates to:
  /// **'Fahrtinfo'**
  String get p_train_journey_appbar_text;

  /// No description provided for @w_reduced_train_journey_title.
  ///
  /// In de, this message translates to:
  /// **'Fahrtübersicht'**
  String get w_reduced_train_journey_title;

  /// No description provided for @w_navigation_drawer_fahrtinfo_title.
  ///
  /// In de, this message translates to:
  /// **'Fahrtinfo'**
  String get w_navigation_drawer_fahrtinfo_title;

  /// No description provided for @w_navigation_drawer_links_title.
  ///
  /// In de, this message translates to:
  /// **'Links'**
  String get w_navigation_drawer_links_title;

  /// No description provided for @w_navigation_drawer_settings_title.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get w_navigation_drawer_settings_title;

  /// No description provided for @w_navigation_drawer_profile_title.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get w_navigation_drawer_profile_title;

  /// No description provided for @p_login_connect_to_tms.
  ///
  /// In de, this message translates to:
  /// **'Mit TMS verbinden'**
  String get p_login_connect_to_tms;

  /// No description provided for @p_login_login_button_text.
  ///
  /// In de, this message translates to:
  /// **'Login'**
  String get p_login_login_button_text;

  /// No description provided for @p_login_login_button_description.
  ///
  /// In de, this message translates to:
  /// **'Mit Ihrem Account einloggen'**
  String get p_login_login_button_description;

  /// No description provided for @p_login_login_failed.
  ///
  /// In de, this message translates to:
  /// **'Login fehlgeschlagen'**
  String get p_login_login_failed;

  /// No description provided for @w_adl_notification_title.
  ///
  /// In de, this message translates to:
  /// **'ADL Meldung'**
  String get w_adl_notification_title;

  /// No description provided for @w_extended_menu_title.
  ///
  /// In de, this message translates to:
  /// **'Weitere Funktionalitäten'**
  String get w_extended_menu_title;

  /// No description provided for @w_extended_menu_maneuver_mode.
  ///
  /// In de, this message translates to:
  /// **'Manövermodus'**
  String get w_extended_menu_maneuver_mode;

  /// No description provided for @w_extended_menu_breaking_slip_action.
  ///
  /// In de, this message translates to:
  /// **'Brems- und Lastzettel öffnen'**
  String get w_extended_menu_breaking_slip_action;

  /// No description provided for @w_extended_menu_transport_document_action.
  ///
  /// In de, this message translates to:
  /// **'Beförderungspapier öffnen'**
  String get w_extended_menu_transport_document_action;

  /// No description provided for @w_extended_menu_journey_overview_action.
  ///
  /// In de, this message translates to:
  /// **'Fahrtübersicht öffnen'**
  String get w_extended_menu_journey_overview_action;

  /// No description provided for @w_extended_menu_journey_wara_action.
  ///
  /// In de, this message translates to:
  /// **'WaRa öffnen'**
  String get w_extended_menu_journey_wara_action;

  /// No description provided for @w_maneuver_notification_text.
  ///
  /// In de, this message translates to:
  /// **'Du befindest dich im Manövermodus. Warnfunktion geschlossenes Signal ist deaktiviert.'**
  String get w_maneuver_notification_text;

  /// No description provided for @w_maneuver_notification_wara_action.
  ///
  /// In de, this message translates to:
  /// **'WaRa'**
  String get w_maneuver_notification_wara_action;

  /// No description provided for @w_maneuver_notification_maneuver.
  ///
  /// In de, this message translates to:
  /// **'Manövrieren'**
  String get w_maneuver_notification_maneuver;

  /// No description provided for @w_koa_notification_title.
  ///
  /// In de, this message translates to:
  /// **'Kundenorientierte Abfahrt'**
  String get w_koa_notification_title;

  /// No description provided for @w_koa_notification_wait.
  ///
  /// In de, this message translates to:
  /// **'Warten eingelegt.'**
  String get w_koa_notification_wait;

  /// No description provided for @w_koa_notification_wait_canceled.
  ///
  /// In de, this message translates to:
  /// **'Warten aufgehoben.'**
  String get w_koa_notification_wait_canceled;

  /// No description provided for @w_koa_notification_departure_process.
  ///
  /// In de, this message translates to:
  /// **'Abfahrprozess anzeigen'**
  String get w_koa_notification_departure_process;

  /// No description provided for @w_departure_process_modal_sheet_title.
  ///
  /// In de, this message translates to:
  /// **'Checkliste Abfahrprozess.'**
  String get w_departure_process_modal_sheet_title;

  /// No description provided for @w_departure_process_modal_sheet_content.
  ///
  /// In de, this message translates to:
  /// **'1. Zustimmung\n2. Zugbeeinflussung\n3. Abfahrtszeit\n4. Türverriegelung\n5. Zustimmung'**
  String get w_departure_process_modal_sheet_content;

  /// No description provided for @w_detail_modal_sheet_radio_channel_label.
  ///
  /// In de, this message translates to:
  /// **'Funkkanal'**
  String get w_detail_modal_sheet_radio_channel_label;

  /// No description provided for @w_detail_modal_sheet_graduated_speed_label.
  ///
  /// In de, this message translates to:
  /// **'Abgestufte Geschwindigkeiten'**
  String get w_detail_modal_sheet_graduated_speed_label;

  /// No description provided for @w_detail_modal_sheet_local_regulations_label.
  ///
  /// In de, this message translates to:
  /// **'Lokale Bestimmungen'**
  String get w_detail_modal_sheet_local_regulations_label;

  /// No description provided for @c_ru_sbb_p.
  ///
  /// In de, this message translates to:
  /// **'SBB'**
  String get c_ru_sbb_p;

  /// No description provided for @c_ru_sbb_c.
  ///
  /// In de, this message translates to:
  /// **'SBB Cargo'**
  String get c_ru_sbb_c;

  /// No description provided for @c_ru_bls_p.
  ///
  /// In de, this message translates to:
  /// **'BLS'**
  String get c_ru_bls_p;

  /// No description provided for @c_ru_bls_c.
  ///
  /// In de, this message translates to:
  /// **'BLS Cargo'**
  String get c_ru_bls_c;

  /// No description provided for @c_ru_sob.
  ///
  /// In de, this message translates to:
  /// **'SOB'**
  String get c_ru_sob;

  /// No description provided for @c_unknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get c_unknown;

  /// No description provided for @c_train_number.
  ///
  /// In de, this message translates to:
  /// **'Zugnummer'**
  String get c_train_number;

  /// No description provided for @c_main_signal_function_entry.
  ///
  /// In de, this message translates to:
  /// **'Einfahrsignal'**
  String get c_main_signal_function_entry;

  /// No description provided for @c_main_signal_function_exit.
  ///
  /// In de, this message translates to:
  /// **'Ausfahrsignal'**
  String get c_main_signal_function_exit;

  /// No description provided for @c_main_signal_function_intermediate.
  ///
  /// In de, this message translates to:
  /// **'Abschnittsignal'**
  String get c_main_signal_function_intermediate;

  /// No description provided for @c_main_signal_function_block.
  ///
  /// In de, this message translates to:
  /// **'Block'**
  String get c_main_signal_function_block;

  /// No description provided for @c_main_signal_function_protection.
  ///
  /// In de, this message translates to:
  /// **'Deckungssignal'**
  String get c_main_signal_function_protection;

  /// No description provided for @c_main_signal_function_laneChange.
  ///
  /// In de, this message translates to:
  /// **'Spurwechsel'**
  String get c_main_signal_function_laneChange;

  /// No description provided for @c_error_code.
  ///
  /// In de, this message translates to:
  /// **'Fehlercode'**
  String get c_error_code;

  /// No description provided for @c_something_went_wrong.
  ///
  /// In de, this message translates to:
  /// **'Da ist was schiefgegangen.'**
  String get c_something_went_wrong;

  /// No description provided for @c_error_connection_failed.
  ///
  /// In de, this message translates to:
  /// **'Verbindung fehlgeschlagen'**
  String get c_error_connection_failed;

  /// No description provided for @c_error_sfera_validation_failed.
  ///
  /// In de, this message translates to:
  /// **'Validierung der Daten fehlgeschlagen'**
  String get c_error_sfera_validation_failed;

  /// No description provided for @c_error_sfera_handshake_rejected.
  ///
  /// In de, this message translates to:
  /// **'Server hat die Verbindung abgelehnt'**
  String get c_error_sfera_handshake_rejected;

  /// No description provided for @c_error_sfera_request_timeout.
  ///
  /// In de, this message translates to:
  /// **'Timeout bei der Anfrage'**
  String get c_error_sfera_request_timeout;

  /// No description provided for @c_error_sfera_jp_unavailable.
  ///
  /// In de, this message translates to:
  /// **'Fahrordnung nicht vorhanden'**
  String get c_error_sfera_jp_unavailable;

  /// No description provided for @c_error_sfera_invalid.
  ///
  /// In de, this message translates to:
  /// **'Unvollständige Daten erhalten'**
  String get c_error_sfera_invalid;

  /// No description provided for @c_connection_track_weiche.
  ///
  /// In de, this message translates to:
  /// **'Weiche'**
  String get c_connection_track_weiche;

  /// No description provided for @c_button_confirm.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get c_button_confirm;

  /// No description provided for @c_radn.
  ///
  /// In de, this message translates to:
  /// **'RADN'**
  String get c_radn;

  /// No description provided for @w_modal_sheet_warn_function_stop_message.
  ///
  /// In de, this message translates to:
  /// **'Halt!'**
  String get w_modal_sheet_warn_function_stop_message;

  /// No description provided for @w_modal_sheet_warn_function_manoeuvre_button.
  ///
  /// In de, this message translates to:
  /// **'Manövrieren'**
  String get w_modal_sheet_warn_function_manoeuvre_button;

  /// No description provided for @w_modal_sheet_warn_function_confirm_button.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen & Schliessen'**
  String get w_modal_sheet_warn_function_confirm_button;

  /// No description provided for @w_modal_sheet_battery_status_battery_almost_empty.
  ///
  /// In de, this message translates to:
  /// **'Batterie fast leer.'**
  String get w_modal_sheet_battery_status_battery_almost_empty;

  /// No description provided for @w_modal_sheet_battery_status_plug_in_device.
  ///
  /// In de, this message translates to:
  /// **'Bitte schliesse dein Gerät am Stromnetz an.'**
  String get w_modal_sheet_battery_status_plug_in_device;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError('AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
