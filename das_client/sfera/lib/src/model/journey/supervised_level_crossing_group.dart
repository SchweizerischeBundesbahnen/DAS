import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class const SupervisedLevelCrossingGroup({
  required super.levelCrossings,
  required final Balise balise,
  required final List<JourneyPoint> pointsBetween,
}) extends LevelCrossingGroup {
  bool canGroupWith(SupervisedLevelCrossingGroup other) {
    return balise.amountLevelCrossings == 1 &&
        levelCrossings.isNotEmpty &&
        pointsBetween.where((it) => it is! Balise && it is! LevelCrossing).isEmpty &&
        other.balise.amountLevelCrossings == 1 &&
        other.levelCrossings.isNotEmpty &&
        other.pointsBetween.where((it) => it is! Balise && it is! LevelCrossing).isEmpty;
  }

  bool shouldShowBaliseIconForLevelCrossing(LevelCrossing levelCrossing) {
    final servicePoint = pointsBetween.whereType<ServicePoint>().firstOrNull;
    return servicePoint != null && servicePoint.order < levelCrossing.order;
  }

  int shownLevelCrossingsCount() {
    return balise.amountLevelCrossings - levelCrossings.where((lc) => shouldShowBaliseIconForLevelCrossing(lc)).length;
  }

  @override
  String toString() {
    return 'SupervisedLevelCrossingGroup{balise: $balise, pointsBetween: $pointsBetween, levelCrossings: $levelCrossings}';
  }
}
