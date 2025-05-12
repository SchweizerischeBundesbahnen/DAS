class TimeController {
  // turn time container gray after 3 minutes of no updates
  int punctualityStaleSeconds = /*180*/ 1;

  // let time container disappear after 5 minutes of no updates
  int punctualityDisappearSeconds = /*300*/ 10;

  void changeTimerPunctualityDisplay(
      {required int newPunctualityGraySeconds, required int newPunctualityDisappearSeconds}) {
    punctualityStaleSeconds = newPunctualityGraySeconds;
    punctualityDisappearSeconds = newPunctualityDisappearSeconds;
  }
}
