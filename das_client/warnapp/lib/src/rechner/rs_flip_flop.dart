class RSFlipFlop {
  RSFlipFlop(int sizeSet, int sizeReset, [this.minimaleAnzahlZwischenZweiSets = 0])
    : _lastSet = List<bool>.filled(sizeSet, false),
      _lastReset = List<bool>.filled(sizeReset, false),
      _updatesCountLetzteErkanntePositiveSchwelle = _kNoPositiveSchwelle;

  // Sentinel-Wert, entspricht NSUIntegerMax im Original.
  static final int _kNoPositiveSchwelle = double.maxFinite.toInt();

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
    final setChangeIndex = _firstRisingEdgeIndex(_lastSet, valuesSet);
    if (setChangeIndex != null) {
      changedSetIndex = setChangeIndex;
      state = true;
    }
    _lastSet = valuesSet;

    // Reset
    if (_lastReset.length != valuesReset.length) {
      throw Exception('Länge von RESET ist ${valuesReset.length} erwartet wird ${_lastReset.length}');
    }
    final resetChangeIndex = _firstRisingEdgeIndex(_lastReset, valuesReset);
    if (resetChangeIndex != null) {
      changedResetIndex = resetChangeIndex;
      state = false;
    }
    _lastReset = valuesReset;

    // Schwellenerkennung
    positiveSchwelleErkannt = !oldState && state;

    // Anzahl Samples zwischen zwei PositivenSchwellen prüfen
    bool doSoftset = false;
    if (positiveSchwelleErkannt) {
      if (_updatesCountLetzteErkanntePositiveSchwelle != _kNoPositiveSchwelle &&
          _updatesCount - _updatesCountLetzteErkanntePositiveSchwelle < minimaleAnzahlZwischenZweiSets) {
        doSoftset = true;
        positiveSchwelleErkannt = false;
      } else {
        _updatesCountLetzteErkanntePositiveSchwelle = _updatesCount;
      }
    }

    // Softset
    final softSetPositivIndex = _firstPositivIndex(valuesSoftSet);
    if (!state && softSetPositivIndex != null) {
      state = true;
      softSetErkannt = true;
      changedSoftSetIndex = softSetPositivIndex;
    } else if (doSoftset) {
      softSetErkannt = true;
      changedSoftSetIndex = valuesSoftSet.length + 1;
    } else {
      softSetErkannt = false;
    }

    // negative Schwellenerkennung
    negativeSchwelleErkannt = oldState && !state;
  }

  /// Gibt den 1-basierten Index des ersten positiven Wertes zurück, sonst null.
  /// Entspricht hasPositivValue:firstPositivIndex: im Original.
  int? _firstPositivIndex(List<bool> newValues) {
    for (int i = 0; i < newValues.length; i++) {
      if (newValues[i]) {
        return i + 1;
      }
    }
    return null;
  }

  /// Gibt den 1-basierten Index der ersten steigenden Flanke zurück, sonst null.
  /// Entspricht hasChanged:other:changedIndex: im Original.
  int? _firstRisingEdgeIndex(List<bool> lastValues, List<bool> newValues) {
    for (int i = 0; i < newValues.length; i++) {
      if (!lastValues[i] && newValues[i]) {
        return i + 1;
      }
    }
    return null;
  }
}
