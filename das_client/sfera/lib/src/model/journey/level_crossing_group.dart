import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class LevelCrossingGroup {
  const LevelCrossingGroup({
    required this.levelCrossings,
  });

  final List<LevelCrossing> levelCrossings;
}
