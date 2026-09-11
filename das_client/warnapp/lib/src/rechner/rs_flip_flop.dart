class RSFlipFlop {
  RSFlipFlop(int sizeSet, int sizeReset, [this.minimaleAnzahlZwischenZweiSets = 0])
    : _lastSet = List<bool>.filled(sizeSet, false),
      _lastReset = List<bool>.filled(sizeReset, false),
      _updatesCountLetzteErkanntePositiveSchwelle = _kNoPositiveSchwelle;

  // Sentinel value, corresponds to NSUIntegerMax in the original.
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

    // Threshold detection
    positiveSchwelleErkannt = !oldState && state;

    // Check number of samples between two positive thresholds
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

    // Soft set
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

    // Negative threshold detection
    negativeSchwelleErkannt = oldState && !state;
  }

  /// Returns the 1-based index of the first positive value, otherwise null.
  /// Corresponds to hasPositivValue:firstPositivIndex: in the original.
  int? _firstPositivIndex(List<bool> newValues) {
    for (int i = 0; i < newValues.length; i++) {
      if (newValues[i]) {
        return i + 1;
      }
    }
    return null;
  }

  /// Returns the 1-based index of the first rising edge, otherwise null.
  /// Corresponds to hasChanged:other:changedIndex: in the original.
  int? _firstRisingEdgeIndex(List<bool> lastValues, List<bool> newValues) {
    for (int i = 0; i < newValues.length; i++) {
      if (!lastValues[i] && newValues[i]) {
        return i + 1;
      }
    }
    return null;
  }
}
