class DelayedTrigger {
  DelayedTrigger(bool initialValue, this.anzahlTrue, this.anzahlFalse)
    : lastTrigger = initialValue,
      state = initialValue;

  bool state;
  bool positiveSchwelleErkannt = false;
  bool negativeSchwelleErkannt = false;
  bool lastTrigger;
  int anzahlTrue;
  int anzahlFalse;

  int _counterTrue = -1;
  int _counterFalse = -1;

  bool updateWithTrigger(bool trigger) {
    final bool oldState = state;

    if (trigger && !lastTrigger) {
      _counterTrue = anzahlTrue;
      _counterFalse = -1;
    } else if (!trigger && lastTrigger) {
      _counterTrue = -1;
      _counterFalse = anzahlFalse;
    }
    lastTrigger = trigger;

    checkDelaySetAndReset();

    positiveSchwelleErkannt = !oldState && state;
    negativeSchwelleErkannt = oldState && !state;

    return state;
  }

  void checkDelaySetAndReset() {
    if (_counterTrue == 0) {
      state = true;
    } else if (_counterFalse == 0) {
      state = false;
    }

    if (_counterTrue >= 0) {
      _counterTrue--;
    }
    if (_counterFalse >= 0) {
      _counterFalse--;
    }
  }
}
