import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class BaliseGroup extends LevelCrossingGroup {
  const BaliseGroup({
    required this.balise,
    required super.levelCrossings,
    required this.pointsBetween,
  });

  final Balise balise;
  final List<JourneyPoint> pointsBetween;

  bool canGroupWith(BaliseGroup other) {
    return balise.amountLevelCrossings == 1 &&
        levelCrossings.isNotEmpty &&
        pointsBetween.isEmpty &&
        other.balise.amountLevelCrossings == 1 &&
        other.levelCrossings.isNotEmpty;
  }

  bool shouldShowBaliseIconForLevelCrossing(LevelCrossing levelCrossing) {
    final servicePoint = pointsBetween.whereType<ServicePoint>().firstOrNull;
    return servicePoint != null && servicePoint.order < levelCrossing.order;
  }

  int shownLevelCrossingsCount() {
    return balise.amountLevelCrossings - levelCrossings.where((lc) => shouldShowBaliseIconForLevelCrossing(lc)).length;
  }
}
