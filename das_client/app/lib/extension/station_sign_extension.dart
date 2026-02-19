import 'package:app/widgets/assets.dart';
import 'package:sfera/component.dart';

extension StationSignExtension on StationSign {
  String iconAsset() {
    return switch (this) {
      .deadendStation => AppAssets.iconDeadendStation,
      .entryOccupiedTrack => AppAssets.iconEntryOccupiedTrack,
      .entryStationWithoutRailFreeAccess => AppAssets.iconEntryStationWithoutRailfreeAccess,
      .noEntryExitSignal => AppAssets.iconNoEntryExitSignal,
      .noEntrySignal => AppAssets.iconNoEntrySignal,
      .noExitSignal => AppAssets.iconNoExitSignal,
      .openLevelCrossingBeforeExitSignal => AppAssets.iconOpenLevelCrossing,
      _ => '',
    };
  }
}
