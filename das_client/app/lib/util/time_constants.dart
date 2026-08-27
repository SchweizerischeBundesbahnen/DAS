import 'package:app/util/animation.dart';

class const TimeConstants() {
  int get punctualityStaleSeconds => 180;

  int get punctualityDisappearSeconds => 300;

  int get automaticAdvancementIdleTimeAutoScroll => 10;

  int get modalSheetAutomaticCloseAfterSeconds => 40;

  int get arrivalDepartureOperationalResetSeconds => 10;

  int get advisedSpeedEndDisplaySeconds => 30;

  int get kmDecisiveGradientResetSeconds => 10;

  int get connectivityLostNotificationDelay => 60;

  int get newShortTermChangesDisplaySeconds => 15;

  Duration get chevronAnimationDuration => DASAnimation.longDuration;
}
