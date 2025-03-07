import 'package:flutter/material.dart';

@immutable
class AppAssets {
  const AppAssets._();

  static const String _dir = 'assets';
  static const String _iconsDir = '$_dir/icons';
  static const String _imagesDir = '$_dir/images';

  // icons
  static const iconHeaderStop = '$_iconsDir/icon_header_stop.svg';
  static const iconStopOnRequest = '$_iconsDir/icon_stop_on_request.svg';
  static const iconProtectionSection = '$_iconsDir/icon_protection_section.svg';
  static const iconAdditionalSpeedRestriction = '$_iconsDir/icon_additional_speed_restriction.svg';
  static const iconCurveStart = '$_iconsDir/icon_curve_start.svg';
  static const iconSignalLaneChange = '$_iconsDir/icon_signal_line_change.svg';
  static const iconCabStart = '$_iconsDir/icon_cab_start.svg';
  static const iconCabEnd = '$_iconsDir/icon_cab_end.svg';
  static const iconIndicatorChecked = '$_iconsDir/icon_indicator_checked.svg';
  static const iconBalise = '$_iconsDir/icon_balise.svg';
  static const iconKmIndicator = '$_iconsDir/icon_km_indicator.svg';
  static const iconWhistle = '$_iconsDir/icon_whistle.svg';
  static const iconTramArea = '$_iconsDir/icon_tram_area.svg';
  static const iconBatteryStatusLow = '$_iconsDir/icon_battery_status_low.svg';

  // images
  static const imageTypeNSignalStop = '$_imagesDir/type_n_signal_stop.svg';
}
