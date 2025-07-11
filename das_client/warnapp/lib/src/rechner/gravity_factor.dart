enum GravityFactorStatusType {
  init,
  fahrtUndefiniert,
  haltAnfang,
  halt,
  fahrt,
  rotation,
  rotationBeendetImHalt,
}

class GravityFactorStatus {
  GravityFactorStatusType type;
  double factor;
  bool disabled;

  GravityFactorStatus(this.type, this.factor, this.disabled);
}

class GravityFactor {
  GravityFactor({GravityFactorStatusType type = GravityFactorStatusType.init}) {
    _alleStatus = [
      GravityFactorStatus(GravityFactorStatusType.init, 1.0, true),
      GravityFactorStatus(GravityFactorStatusType.fahrtUndefiniert, 0.0002, false),
      GravityFactorStatus(GravityFactorStatusType.haltAnfang, 1.0, true),
      GravityFactorStatus(GravityFactorStatusType.halt, 0.01, false),
      GravityFactorStatus(GravityFactorStatusType.fahrt, 0.0001, false),
      GravityFactorStatus(GravityFactorStatusType.rotation, 1.0, true),
      GravityFactorStatus(GravityFactorStatusType.rotationBeendetImHalt, 0.01, false),
    ];
    _aktuellerStatus = _alleStatus[type.index];
  }

  late List<GravityFactorStatus> _alleStatus;
  late GravityFactorStatus _aktuellerStatus;
  int anzahlUpdatesSeitStatuswechsel = 0;

  void updateWithFahrt(bool fahrt, bool drehung, bool handbewegung) {
    if (drehung) {
      _changeStatus(GravityFactorStatusType.rotation);
    } else if (handbewegung && !fahrt) {
      _changeStatus(GravityFactorStatusType.rotation);
    } else {
      switch (_aktuellerStatus.type) {
        case GravityFactorStatusType.haltAnfang:
          _changeStatus(fahrt ? GravityFactorStatusType.fahrt : GravityFactorStatusType.halt);
          break;
        case GravityFactorStatusType.halt:
          if (fahrt) {
            _changeStatus(GravityFactorStatusType.fahrt);
          }
          break;
        case GravityFactorStatusType.fahrt:
          if (!fahrt) {
            _changeStatus(GravityFactorStatusType.haltAnfang);
          }
          break;
        case GravityFactorStatusType.init:
          if (anzahlUpdatesSeitStatuswechsel > 1) {
            _changeStatus(fahrt ? GravityFactorStatusType.fahrtUndefiniert : GravityFactorStatusType.halt);
          }
          break;
        case GravityFactorStatusType.fahrtUndefiniert:
          if (!fahrt) {
            _changeStatus(GravityFactorStatusType.haltAnfang);
          }
          break;
        case GravityFactorStatusType.rotation:
          _changeStatus(
            fahrt ? GravityFactorStatusType.fahrtUndefiniert : GravityFactorStatusType.rotationBeendetImHalt,
          );
          break;
        case GravityFactorStatusType.rotationBeendetImHalt:
          if (fahrt) {
            _changeStatus(GravityFactorStatusType.fahrtUndefiniert);
          } else {
            if (anzahlUpdatesSeitStatuswechsel > 50) {
              _changeStatus(GravityFactorStatusType.halt);
            }
          }
          break;
      }
    }
    anzahlUpdatesSeitStatuswechsel++;
  }

  void _changeStatus(GravityFactorStatusType newStatus) {
    if (_aktuellerStatus.type != newStatus) {
      _aktuellerStatus = _alleStatus[newStatus.index];
      anzahlUpdatesSeitStatuswechsel = 0;
    }
  }

  double get factor => _aktuellerStatus.factor;

  bool get disabled => _aktuellerStatus.disabled;

  // zu Testzwecken
  GravityFactorStatusType get type => _aktuellerStatus.type;
}
