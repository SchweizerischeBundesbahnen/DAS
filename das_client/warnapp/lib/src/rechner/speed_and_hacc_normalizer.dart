class SpeedAndHaccNormalizer {
  final int gueltigkeitsDauer;
  final double haccUntereSchwelle;
  final double haccObereSchwelle;
  final int haccObereSchwelleAnzahl;
  double speed = -1.0;
  int anzahlGueltigeSignale = 0;
  int anzahlGueltigeSignaleUnterHaccObereSchwelle = 0;

  SpeedAndHaccNormalizer(
    this.gueltigkeitsDauer,
    this.haccUntereSchwelle,
    this.haccObereSchwelle,
    this.haccObereSchwelleAnzahl,
  );

  double updateWithSpeed(double speed, double timestamp, double horizontalAccuracy) {
    if (timestamp > 0) {
      this.speed = speed;
      anzahlGueltigeSignale = 0;
      if (horizontalAccuracy > haccUntereSchwelle) {
        if (horizontalAccuracy <= haccObereSchwelle) {
          anzahlGueltigeSignaleUnterHaccObereSchwelle++;
          if (anzahlGueltigeSignaleUnterHaccObereSchwelle <= haccObereSchwelleAnzahl) {
            this.speed = -1.0;
          }
        } else {
          anzahlGueltigeSignaleUnterHaccObereSchwelle = 0;
          this.speed = -1.0;
        }
      } else {
        anzahlGueltigeSignaleUnterHaccObereSchwelle = 0;
      }
    } else {
      anzahlGueltigeSignale++;
      if (anzahlGueltigeSignale >= gueltigkeitsDauer) {
        this.speed = -1.0;
      }
    }
    return this.speed;
  }
}
