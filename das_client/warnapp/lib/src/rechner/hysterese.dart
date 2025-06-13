class Hysterese {
  Hysterese({
    required this.state,
    required this.anzahlPositiv,
    required this.schwellePositiv,
    required this.anzahlNegativ,
    required this.schwelleNegativ,
    bool absolut = false,
  }) : _absolut = absolut {
    if (schwelleNegativ > schwellePositiv) {
      throw ArgumentError('schwelleNegativ > schwellePositiv');
    }
  }

  bool state;
  final int anzahlPositiv;
  final double schwellePositiv;
  final int anzahlNegativ;
  final double schwelleNegativ;
  bool positiveSchwelleErkannt = false;
  bool negativeSchwelleErkannt = false;
  int _counter = 0;
  final bool _absolut;

  bool update(double updateValue) {
    final value = _absolut ? updateValue.abs() : updateValue;
    positiveSchwelleErkannt = false;
    negativeSchwelleErkannt = false;

    if (!state) {
      if (value >= schwellePositiv && _counter >= anzahlPositiv) {
        positiveSchwelleErkannt = true;
        state = true;
        _counter = 0;
      }

      if (value >= schwellePositiv) {
        _counter++;
      } else {
        _counter = 0;
      }
    } else {
      if (value <= schwelleNegativ && _counter >= anzahlNegativ) {
        negativeSchwelleErkannt = true;
        state = false;
        _counter = 0;
      }

      if (value <= schwelleNegativ) {
        _counter++;
      } else {
        _counter = 0;
      }
    }
    return state;
  }
}
