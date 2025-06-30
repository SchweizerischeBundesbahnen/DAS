import 'package:app/widgets/assets.dart';
import 'package:sfera/component.dart';

extension StationSignExtension on StationSign {
  String displayIcon() {
    return switch (this) {
      StationSign.deadendStation => AppAssets.iconDeadendStation,
      StationSign.entryOccupiedTrack => AppAssets.iconEntryOccupiedTrack,
      StationSign.entryStationWithoutRailfreeAccess => AppAssets.iconEntryStationWithoutRailfreeAccess,
      StationSign.noEntryExitSignal => AppAssets.iconNoEntryExitSignal,
      StationSign.noEntrySignal => AppAssets.iconNoEntrySignal,
      StationSign.noExitSignal => AppAssets.iconNoExitSignal,
      StationSign.openLevelCrossingBeforeExitSignal => AppAssets.iconOpenLevelCrossingBeforeExitSignal,
      _ => '',
    };
  }
}
