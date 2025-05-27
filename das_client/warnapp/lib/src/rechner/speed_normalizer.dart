class SpeedNormalizer {
  final int gueltigkeitsDauer;
  double speed = -1.0;
  int anzahlGueltigeSignale = 0;

  SpeedNormalizer(this.gueltigkeitsDauer);

  double updateWithSpeed(double speed, double timestamp) {
    if (timestamp > 0) {
      this.speed = speed;
      anzahlGueltigeSignale = 0;
    } else {
      anzahlGueltigeSignale++;
      if (anzahlGueltigeSignale >= gueltigkeitsDauer) {
        this.speed = -1.0;
      }
    }
    return this.speed;
  }
}
