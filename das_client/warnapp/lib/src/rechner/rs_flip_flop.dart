class RSFlipFlop {
  RSFlipFlop(int sizeSet, int sizeReset, [this.minimaleAnzahlZwischenZweiSets = 0])
    : _lastSet = List<bool>.filled(sizeSet, false),
      _lastReset = List<bool>.filled(sizeReset, false),
      _updatesCountLetzteErkanntePositiveSchwelle = double.maxFinite.toInt();

  List<bool> _lastSet;
  List<bool> _lastReset;
  int _updatesCountLetzteErkanntePositiveSchwelle;
  int _updatesCount = 0;

  bool state = false;
  bool positiveSchwelleErkannt = false;
  bool softSetErkannt = false;
  bool negativeSchwelleErkannt = false;
  int minimaleAnzahlZwischenZweiSets;

  int changedSoftSetIndex = 0;
  int changedSetIndex = 0;
  int changedResetIndex = 0;

  void set(List<bool> valuesSet, List<bool> valuesSoftSet, List<bool> valuesReset) {
    final oldState = state;
    _updatesCount++;

    // Set
    if (_lastSet.length != valuesSet.length) {
      throw Exception('Länge von SET ist ${valuesSet.length} erwartet wird ${_lastSet.length}');
    }
    final changedSetIndex = 0;
    if (_hasChanged(_lastSet, valuesSet, changedSetIndex)) {
      state = true;
    }
    _lastSet = valuesSet;

    // Reset
    if (_lastReset.length != valuesReset.length) {
      throw Exception('Länge von RESET ist ${valuesReset.length} erwartet wird ${_lastReset.length}');
    }
    final changedResetIndex = 0;
    if (_hasChanged(_lastReset, valuesReset, changedResetIndex)) {
      state = false;
    }
    _lastReset = valuesReset;

    // Schwellenerkennung
    positiveSchwelleErkannt = !oldState && state;

    // Anzahl Samples zwischen zwei PositivenSchwellen prüfen
    bool doSoftset = false;
    if (positiveSchwelleErkannt) {
      if (_updatesCountLetzteErkanntePositiveSchwelle != double.maxFinite.toInt() &&
          _updatesCount - _updatesCountLetzteErkanntePositiveSchwelle < minimaleAnzahlZwischenZweiSets) {
        doSoftset = true;
        positiveSchwelleErkannt = false;
      } else {
        _updatesCountLetzteErkanntePositiveSchwelle = _updatesCount;
      }
    }

    // Softset
    final changedSoftSetIndex = 0;
    if (!state && _hasPositivValue(valuesSoftSet, changedSoftSetIndex)) {
      state = true;
      softSetErkannt = true;
      this.changedSoftSetIndex = changedSoftSetIndex;
    } else if (doSoftset) {
      softSetErkannt = true;
      this.changedSoftSetIndex = valuesSoftSet.length + 1;
    } else {
      softSetErkannt = false;
    }

    // negative Schwellenerkennung
    negativeSchwelleErkannt = oldState && !state;
  }

  bool _hasPositivValue(List<bool> newValues, int firstPositivIndex) {
    for (int i = 0; i < newValues.length; i++) {
      if (newValues[i]) {
        firstPositivIndex = i + 1;
        return true;
      }
    }
    return false;
  }

  bool _hasChanged(List<bool> lastValues, List<bool> newValues, int changedIndex) {
    for (int i = 0; i < newValues.length; i++) {
      if (!lastValues[i] && newValues[i]) {
        changedIndex = i + 1;
        return true;
      }
    }
    return false;
  }
}
