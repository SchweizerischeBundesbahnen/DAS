import 'package:collection/collection.dart';

enum StationSign {
  deadendStation('Q'),
  entryOccupiedTrack('Z'),
  entryStationWithoutRailFreeAccess('M'),
  noEntryExitSignal('N'),
  noEntrySignal('O'),
  noExitSignal('P'),
  openLevelCrossingBeforeExitSignal('C'),
  unknown('UNKNOWN');

  final String? value;

  const StationSign(this.value);

  factory StationSign.from(String value) {
    return values.firstWhere((element) => element.value == value.toUpperCase(), orElse: () => StationSign.unknown);
  }

  static StationSign? fromOptional(String? value) => values.firstWhereOrNull(
    (e) => e.value == value?.toUpperCase(),
  );
}
