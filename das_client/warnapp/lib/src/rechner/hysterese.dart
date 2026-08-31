class Hysterese({
  required var bool state,
  required final int anzahlPositiv,
  required final double schwellePositiv,
  required final int anzahlNegativ,
  required final double schwelleNegativ,
  final bool _absolut = false,
}) {
  this {
    if (schwelleNegativ > schwellePositiv) {
      throw ArgumentError('schwelleNegativ > schwellePositiv');
    }
  }

  bool positiveSchwelleErkannt = false;
  bool negativeSchwelleErkannt = false;
  int _counter = 0;

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
