import 'package:app/widgets/assets.dart';
import 'package:sfera/component.dart';

extension StationSignExtension on StationSign {
  String iconAsset() {
    return switch (this) {
      StationSign.deadendStation => AppAssets.iconDeadendStation,
      StationSign.entryOccupiedTrack => AppAssets.iconEntryOccupiedTrack,
      StationSign.entryStationWithoutRailFreeAccess => AppAssets.iconEntryStationWithoutRailfreeAccess,
      StationSign.noEntryExitSignal => AppAssets.iconNoEntryExitSignal,
      StationSign.noEntrySignal => AppAssets.iconNoEntrySignal,
      StationSign.noExitSignal => AppAssets.iconNoExitSignal,
      StationSign.openLevelCrossingBeforeExitSignal => AppAssets.iconOpenLevelCrossingBeforeExitSignal,
      _ => '',
    };
  }
}
