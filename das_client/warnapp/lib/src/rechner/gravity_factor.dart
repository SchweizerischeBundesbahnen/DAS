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
  GravityFactor({GravityFactorStatusType type = .init}) {
    _alleStatus = [
      GravityFactorStatus(.init, 1.0, true),
      GravityFactorStatus(.fahrtUndefiniert, 0.0002, false),
      GravityFactorStatus(.haltAnfang, 1.0, true),
      GravityFactorStatus(.halt, 0.01, false),
      GravityFactorStatus(.fahrt, 0.0001, false),
      GravityFactorStatus(.rotation, 1.0, true),
      GravityFactorStatus(.rotationBeendetImHalt, 0.01, false),
    ];
    _aktuellerStatus = _alleStatus[type.index];
  }

  late List<GravityFactorStatus> _alleStatus;
  late GravityFactorStatus _aktuellerStatus;
  int anzahlUpdatesSeitStatuswechsel = 0;

  void updateWithFahrt(bool fahrt, bool drehung, bool handbewegung) {
    if (drehung) {
      _changeStatus(.rotation);
    } else if (handbewegung && !fahrt) {
      _changeStatus(.rotation);
    } else {
      switch (_aktuellerStatus.type) {
        case .haltAnfang:
          _changeStatus(fahrt ? .fahrt : .halt);
          break;
        case .halt:
          if (fahrt) {
            _changeStatus(.fahrt);
          }
          break;
        case .fahrt:
          if (!fahrt) {
            _changeStatus(.haltAnfang);
          }
          break;
        case .init:
          if (anzahlUpdatesSeitStatuswechsel > 1) {
            _changeStatus(fahrt ? .fahrtUndefiniert : .halt);
          }
          break;
        case .fahrtUndefiniert:
          if (!fahrt) {
            _changeStatus(.haltAnfang);
          }
          break;
        case .rotation:
          _changeStatus(
            fahrt ? .fahrtUndefiniert : .rotationBeendetImHalt,
          );
          break;
        case .rotationBeendetImHalt:
          if (fahrt) {
            _changeStatus(.fahrtUndefiniert);
          } else {
            if (anzahlUpdatesSeitStatuswechsel > 50) {
              _changeStatus(.halt);
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
