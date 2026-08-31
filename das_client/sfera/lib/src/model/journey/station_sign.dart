import 'package:collection/collection.dart';

enum StationSign(final String? value) {
  deadendStation('Q'),
  entryOccupiedTrack('Z'),
  entryStationWithoutRailFreeAccess('M'),
  noEntryExitSignal('N'),
  noEntrySignal('O'),
  noExitSignal('P'),
  openLevelCrossingBeforeExitSignal('C'),
  unknown('UNKNOWN');

  factory from(String value) =>
      values.firstWhere((element) => element.value == value.toUpperCase(), orElse: () => .unknown);

  static StationSign? fromOptional(String? value) => values.firstWhereOrNull((e) => e.value == value?.toUpperCase());
}
