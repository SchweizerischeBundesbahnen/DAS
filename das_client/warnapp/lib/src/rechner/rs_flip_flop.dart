class RSFlipFlop {
  bool state = false;
  bool positiveSchwelleErkannt = false;
  bool softSetErkannt = false;
  bool negativeSchwelleErkannt = false;
  late List<bool> lastSet;
  late List<bool> lastReset;
  late int updatesCountLetzteErkanntePositiveSchwelle;
  int minimaleAnzahlZwischenZweiSets;
  int updatesCount = 0;

  int changedSoftSetIndex = 0;
  int changedSetIndex = 0;
  int changedResetIndex = 0;

  RSFlipFlop(int sizeSet, int sizeReset, [this.minimaleAnzahlZwischenZweiSets = 0]) {
    lastSet = List<bool>.filled(sizeSet, false);
    lastReset = List<bool>.filled(sizeReset, false);
    updatesCountLetzteErkanntePositiveSchwelle = double.maxFinite.toInt(); // equivalent to NSUIntegerMax
  }

  void set(List<bool> valuesSet, List<bool> valuesSoftSet, List<bool> valuesReset) {
    final oldState = state;
    updatesCount++;

    // Set
    if (lastSet.length != valuesSet.length) {
      throw Exception('Länge von SET ist ${valuesSet.length} erwartet wird ${lastSet.length}');
    }
    final changedSetIndex = 0;
    if (hasChanged(lastSet, valuesSet, changedSetIndex)) {
      state = true;
    }
    lastSet = valuesSet;

    // Reset
    if (lastReset.length != valuesReset.length) {
      throw Exception('Länge von RESET ist ${valuesReset.length} erwartet wird ${lastReset.length}');
    }
    final changedResetIndex = 0;
    if (hasChanged(lastReset, valuesReset, changedResetIndex)) {
      state = false;
    }
    lastReset = valuesReset;

    // Schwellenerkennung
    positiveSchwelleErkannt = !oldState && state;

    // Anzahl Samples zwischen zwei PositivenSchwellen prüfen
    bool doSoftset = false;
    if (positiveSchwelleErkannt) {
      if (updatesCountLetzteErkanntePositiveSchwelle != double.maxFinite.toInt() &&
          updatesCount - updatesCountLetzteErkanntePositiveSchwelle < minimaleAnzahlZwischenZweiSets) {
        doSoftset = true;
        positiveSchwelleErkannt = false;
      } else {
        updatesCountLetzteErkanntePositiveSchwelle = updatesCount;
      }
    }

    // Softset
    final changedSoftSetIndex = 0;
    if (!state && hasPositivValue(valuesSoftSet, changedSoftSetIndex)) {
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

  bool hasPositivValue(List<bool> newValues, int firstPositivIndex) {
    for (int i = 0; i < newValues.length; i++) {
      if (newValues[i]) {
        firstPositivIndex = i + 1;
        return true;
      }
    }
    return false;
  }

  bool hasChanged(List<bool> lastValues, List<bool> newValues, int changedIndex) {
    for (int i = 0; i < newValues.length; i++) {
      if (!lastValues[i] && newValues[i]) {
        changedIndex = i + 1;
        return true;
      }
    }
    return false;
  }
}
