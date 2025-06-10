class FlipFlop {
  FlipFlop(bool initialValue) : state = initialValue, _lastTrigger = initialValue;

  bool _lastTrigger;
  bool state;
  bool positiveSchwelleErkannt = false;
  bool negativeSchwelleErkannt = false;

  bool updateWithTrigger(bool trigger, {bool disablePositiv = false, bool disableNegativ = false}) {
    final bool oldState = state;

    if (trigger && !_lastTrigger && !disablePositiv) {
      state = true;
    } else if (!trigger && _lastTrigger && !disableNegativ) {
      state = false;
    }
    _lastTrigger = trigger;

    positiveSchwelleErkannt = !oldState && state;
    negativeSchwelleErkannt = oldState && !state;

    return state;
  }
}
