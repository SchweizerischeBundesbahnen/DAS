enum TrainSeries {
  A,
  D,
  N,
  O,
  R,
  W,
  S;

  factory TrainSeries.from(String value) {
    return values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
    );
  }
}
