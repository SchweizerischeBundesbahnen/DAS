class Hysterese {
  bool state;
  bool positiveSchwelleErkannt = false;
  bool negativeSchwelleErkannt = false;
  final int anzahlPositiv;
  final double schwellePositiv;
  final int anzahlNegativ;
  final double schwelleNegativ;
  int counter = 0;
  final bool absolut;

  Hysterese({
    required this.state,
    required this.anzahlPositiv,
    required this.schwellePositiv,
    required this.anzahlNegativ,
    required this.schwelleNegativ,
    this.absolut = false,
  }) {
    if (schwelleNegativ > schwellePositiv) {
      throw ArgumentError('schwelleNegativ > schwellePositiv');
    }
  }

  bool update(double updateValue) {
    final value = absolut ? updateValue.abs() : updateValue;
    positiveSchwelleErkannt = false;
    negativeSchwelleErkannt = false;

    if (!state) {
      if (value >= schwellePositiv && counter >= anzahlPositiv) {
        positiveSchwelleErkannt = true;
        state = true;
        counter = 0;
      }

      if (value >= schwellePositiv) {
        counter++;
      } else {
        counter = 0;
      }
    } else {
      if (value <= schwelleNegativ && counter >= anzahlNegativ) {
        negativeSchwelleErkannt = true;
        state = false;
        counter = 0;
      }

      if (value <= schwelleNegativ) {
        counter++;
      } else {
        counter = 0;
      }
    }
    return state;
  }
}
