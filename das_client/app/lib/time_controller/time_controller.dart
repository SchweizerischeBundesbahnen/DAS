class TimeController {
  // change punctuality text to stale after 3 minutes
  int punctualityStaleSeconds = 180;

  // let punctuality text disappear after 5 minutes
  int punctualityDisappearSeconds = 300;

  // set idle time of DAS Modal sheet to 10 seconds
  int idleTimeDASModalSheet = 10;

  // set idle time of scroll in automatic advancement to 10 seconds
  int idleTimeAutoScroll = 10;

  // change punctuality text timers when no update are received
  void changeTimerPunctualityDisplay({
    required int newPunctualityGraySeconds,
    required int newPunctualityDisappearSeconds,
  }) {
    punctualityStaleSeconds = newPunctualityGraySeconds;
    punctualityDisappearSeconds = newPunctualityDisappearSeconds;
  }

  // change idle time in DAS modal sheet
  void changeIdleTimeDASModalSheet({required int newIdleTimeInSeconds}) {
    idleTimeDASModalSheet = newIdleTimeInSeconds;
  }

  // change scroll idle time in automatic advancement
  void changeIdleTimeAutoScroll({required int newIdleTimeAutoScroll}) {
    idleTimeAutoScroll = newIdleTimeAutoScroll;
  }
}
