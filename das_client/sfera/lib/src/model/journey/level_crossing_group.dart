import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
abstract class const LevelCrossingGroup({
  required final List<LevelCrossing> levelCrossings,
});
