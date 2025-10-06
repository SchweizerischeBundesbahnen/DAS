import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class UnsupervisedLevelCrossingGroup extends LevelCrossingGroup {
  const UnsupervisedLevelCrossingGroup({
    required super.levelCrossings,
  });
}
