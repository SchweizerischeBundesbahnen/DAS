enum StationSign {
  deadendStation('Q'),
  entryOccupiedTrack('Z'),
  entryStationWithoutRailfreeAccess('M'),
  noEntryExitSignal('N'),
  noEntrySignal('O'),
  noExitSignal('P'),
  openLevelCrossingBeforeExitSignal('C'),
  unknown('Unknown');

  final String value;

  const StationSign(this.value);

  factory StationSign.from(String value) {
    return values.firstWhere((element) => element.value == value.toUpperCase(), orElse: () => StationSign.unknown);
  }
}
