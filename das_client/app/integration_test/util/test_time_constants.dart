import 'package:app/util/time_constants.dart';

class TestTimeConstants extends TimeConstants {
  @override
  int get punctualityStaleSeconds => 2;

  @override
  int get punctualityDisappearSeconds => 4;

  @override
  int get automaticAdvancementIdleTimeAutoScroll => 2;

  @override
  int get modalSheetAutomaticCloseAfterSeconds => 2;

  @override
  int get arrivalDepartureOperationalResetSeconds => 2;

  @override
  int get adlEndDisplaySeconds => 2;

  @override
  int get kmDecisiveGradientResetSeconds => 2;

  @override
  int get connectivityLostNotificationDelay => 2;
}
