class SignalKeeper {
  double _lastResult = 0.0;
  double _factor = 1.0;

  SignalKeeper();

  void setFactor(double factor) {
    if (factor > 1.0) {
      _factor = 1.0;
    } else if (factor < 0.0) {
      _factor = 0.0;
    } else {
      _factor = factor;
    }
  }

  double updateWithValue(double value, double factor) {
    setFactor(factor);
    _lastResult = (value * _factor) + (_lastResult * (1.0 - _factor));
    return _lastResult;
  }

  double get value => _lastResult;
}
