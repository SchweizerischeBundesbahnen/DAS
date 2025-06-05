class SpeedNormalizer {
  SpeedNormalizer(this._gueltigkeitsDauer);

  final int _gueltigkeitsDauer;
  int _anzahlGueltigeSignale = 0;
  double speed = -1.0;

  double updateWithSpeed(double speed, double timestamp) {
    if (timestamp > 0) {
      this.speed = speed;
      _anzahlGueltigeSignale = 0;
    } else {
      _anzahlGueltigeSignale++;
      if (_anzahlGueltigeSignale >= _gueltigkeitsDauer) {
        this.speed = -1.0;
      }
    }
    return this.speed;
  }
}
