import 'package:app/util/time_constants.dart';

class TestTimeConstants extends TimeConstants {
  int modalSheetAutomaticCloseAfterSecondsValue = 2;

  @override
  int get punctualityStaleSeconds => 2;

  @override
  int get punctualityDisappearSeconds => 5;

  @override
  int get automaticAdvancementIdleTimeAutoScroll => 2;

  @override
  int get modalSheetAutomaticCloseAfterSeconds => modalSheetAutomaticCloseAfterSecondsValue;

  @override
  int get arrivalDepartureOperationalResetSeconds => 2;

  @override
  int get advisedSpeedEndDisplaySeconds => 2;

  @override
  int get kmDecisiveGradientResetSeconds => 2;

  @override
  int get connectivityLostNotificationDelay => 2;

  @override
  int get newShortTermChangesDisplaySeconds => 2;

  @override
  int get httpRequestRetryDelaySeconds => 2;
}
