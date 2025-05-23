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
  int counterTrue = -1;
  int counterFalse = -1;

  bool updateWithTrigger(bool trigger) {
    bool oldState = state;

    if (trigger && !lastTrigger) {
      counterTrue = anzahlTrue;
      counterFalse = -1;
    } else if (!trigger && lastTrigger) {
      counterTrue = -1;
      counterFalse = anzahlFalse;
    }
    lastTrigger = trigger;

    checkDelaySetAndReset();

    positiveSchwelleErkannt = !oldState && state;
    negativeSchwelleErkannt = oldState && !state;

    return state;
  }

  void checkDelaySetAndReset() {
    if (counterTrue == 0) {
      state = true;
    } else if (counterFalse == 0) {
      state = false;
    }

    if (counterTrue >= 0) {
      counterTrue--;
    }
    if (counterFalse >= 0) {
      counterFalse--;
    }
  }
}
