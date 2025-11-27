import 'package:flutter/material.dart';

@immutable
class AppAssets {
  const AppAssets._();

  static const String _dir = 'assets';
  static const String _iconsDir = '$_dir/icons';
  static const String _othersDir = '$_dir/others';
  static const String _soundsDir = 'sounds';

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
  static const iconKoaWait = '$_iconsDir/icon_koa_wait.svg';
  static const iconDeadendStation = '$_iconsDir/icon_deadend_station.svg';
  static const iconEntryOccupiedTrack = '$_iconsDir/icon_entry_occupied_track.svg';
  static const iconEntryStationWithoutRailfreeAccess = '$_iconsDir/icon_entry_station_without_railfree_access.svg';
  static const iconNoEntryExitSignal = '$_iconsDir/icon_no_entry_exit_signal.svg';
  static const iconNoEntrySignal = '$_iconsDir/icon_no_entry_signal.svg';
  static const iconNoExitSignal = '$_iconsDir/icon_no_exit_signal.svg';
  static const iconOpenLevelCrossingBeforeExitSignal = '$_iconsDir/icon_open_level_crossing_before_exit_signal.svg';
  static const iconReducedSpeed = '$_iconsDir/icon_reduced_speed.svg';
  static const iconAdvisedSpeedFixedTime = '$_iconsDir/icon_advised_speed_fixed_time.svg';
  static const iconAdvisedSpeedFollowTrain = '$_iconsDir/icon_advised_speed_follow_train.svg';
  static const iconAdvisedSpeedTrainFollowing = '$_iconsDir/icon_advised_speed_train_following.svg';
  static const iconWifi = '$_iconsDir/icon_wifi.svg';
  static const iconWifiDisabled = '$_iconsDir/icon_wifi_disabled.svg';
  static const iconExclamationPoint = '$_iconsDir/icon_exclamation_point.svg';
  static const iconSimZug = '$_iconsDir/icon_sim_zug.svg';
  static const iconSignExclamationPoint = '$_iconsDir/icon_sign_exclamation_point.svg';

  // others
  static const imageTypeNSignalStop = '$_othersDir/type_n_signal_stop.svg';
  static const shapeMenuArrow = '$_othersDir/shape_menu_arrow.svg';
  static const sbbTrain = '$_othersDir/sbb-train.svg';
  static const blsTrain = '$_othersDir/bls-train.svg';
  static const sobTrain = '$_othersDir/sob-train.svg';
  static const shapeRoundedEdgeLeft = '$_othersDir/shape_rounded_edge_left.svg';

  // audio
  static const soundKoaWaitCanceled = '$_soundsDir/koa_wait_canceled.mp3';
  static const soundWarnappWarn = '$_soundsDir/warnapp_warn.wav';
  static const soundAdvisedSpeedStart = '$_soundsDir/advised_speed_start.wav';
  static const soundAdvisedSpeedEnd = '$_soundsDir/advised_speed_end.wav';
}
