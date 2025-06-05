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
    alleStatus = [
      GravityFactorStatus(GravityFactorStatusType.init, 1.0, true),
      GravityFactorStatus(GravityFactorStatusType.fahrtUndefiniert, 0.0002, false),
      GravityFactorStatus(GravityFactorStatusType.haltAnfang, 1.0, true),
      GravityFactorStatus(GravityFactorStatusType.halt, 0.01, false),
      GravityFactorStatus(GravityFactorStatusType.fahrt, 0.0001, false),
      GravityFactorStatus(GravityFactorStatusType.rotation, 1.0, true),
      GravityFactorStatus(GravityFactorStatusType.rotationBeendetImHalt, 0.01, false),
    ];
    aktuellerStatus = alleStatus[type.index];
  }

  late List<GravityFactorStatus> alleStatus;
  late GravityFactorStatus aktuellerStatus;
  int anzahlUpdatesSeitStatuswechsel = 0;

  void updateWithFahrt(bool fahrt, bool drehung, bool handbewegung) {
    if (drehung) {
      changeStatus(GravityFactorStatusType.rotation);
    } else if (handbewegung && !fahrt) {
      changeStatus(GravityFactorStatusType.rotation);
    } else {
      switch (aktuellerStatus.type) {
        case GravityFactorStatusType.haltAnfang:
          changeStatus(fahrt ? GravityFactorStatusType.fahrt : GravityFactorStatusType.halt);
          break;
        case GravityFactorStatusType.halt:
          if (fahrt) {
            changeStatus(GravityFactorStatusType.fahrt);
          }
          break;
        case GravityFactorStatusType.fahrt:
          if (!fahrt) {
            changeStatus(GravityFactorStatusType.haltAnfang);
          }
          break;
        case GravityFactorStatusType.init:
          if (anzahlUpdatesSeitStatuswechsel > 1) {
            changeStatus(fahrt ? GravityFactorStatusType.fahrtUndefiniert : GravityFactorStatusType.halt);
          }
          break;
        case GravityFactorStatusType.fahrtUndefiniert:
          if (!fahrt) {
            changeStatus(GravityFactorStatusType.haltAnfang);
          }
          break;
        case GravityFactorStatusType.rotation:
          changeStatus(
            fahrt ? GravityFactorStatusType.fahrtUndefiniert : GravityFactorStatusType.rotationBeendetImHalt,
          );
          break;
        case GravityFactorStatusType.rotationBeendetImHalt:
          if (fahrt) {
            changeStatus(GravityFactorStatusType.fahrtUndefiniert);
          } else {
            if (anzahlUpdatesSeitStatuswechsel > 50) {
              changeStatus(GravityFactorStatusType.halt);
            }
          }
          break;
      }
    }
    anzahlUpdatesSeitStatuswechsel++;
  }

  void changeStatus(GravityFactorStatusType newStatus) {
    if (aktuellerStatus.type != newStatus) {
      aktuellerStatus = alleStatus[newStatus.index];
      anzahlUpdatesSeitStatuswechsel = 0;
    }
  }

  double get factor => aktuellerStatus.factor;

  bool get disabled => aktuellerStatus.disabled;

  // zu Testzwecken
  GravityFactorStatusType get type => aktuellerStatus.type;
}
