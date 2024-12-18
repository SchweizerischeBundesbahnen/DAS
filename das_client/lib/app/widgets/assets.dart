import 'package:flutter/material.dart';

@immutable
class AppAssets {
  const AppAssets._();

  static const String _dir = 'assets';
  static const String _iconsDir = '$_dir/icons';

  static const iconHeaderStop = '$_iconsDir/icon_header_stop.svg';
  static const iconStopOnRequest = '$_iconsDir/icon_stop_on_request.svg';
  static const iconProtectionSection = '$_iconsDir/icon_protection_section.svg';
  static const iconAdditionalSpeedRestriction = '$_iconsDir/icon_additional_speed_restriction.svg';
  static const iconCurveStart = '$_iconsDir/icon_curve_start.svg';
  static const iconSignalLaneChange = '$_iconsDir/icon_signal_line_change.svg';
  static const iconCabStart = '$_iconsDir/icon_cab_start.svg';
  static const iconCabEnd = '$_iconsDir/icon_cab_end.svg';
  static const iconIndicatorChecked = '$_iconsDir/icon_indicator_checked.svg';
}
