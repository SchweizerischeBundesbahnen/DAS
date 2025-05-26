class FlipFlop {
  bool state;
  bool lastTrigger;
  bool positiveSchwelleErkannt = false;
  bool negativeSchwelleErkannt = false;

  FlipFlop(bool initialValue)
      : state = initialValue,
        lastTrigger = initialValue;

  bool updateWithTrigger(bool trigger, {bool disablePositiv = false, bool disableNegativ = false}) {
    final bool oldState = state;

    if (trigger && !lastTrigger && !disablePositiv) {
      state = true;
    } else if (!trigger && lastTrigger && !disableNegativ) {
      state = false;
    }
    lastTrigger = trigger;

    positiveSchwelleErkannt = !oldState && state;
    negativeSchwelleErkannt = oldState && !state;

    return state;
  }
}
