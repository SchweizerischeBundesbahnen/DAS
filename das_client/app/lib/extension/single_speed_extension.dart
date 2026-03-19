import 'package:sfera/component.dart';

extension SingleSpeedExtension on SingleSpeed {
  bool isLargerThan(Speed? other) {
    if (other == null) return false;
    if (other.isIllegal) return false;
    if (other is! SingleSpeed) return false;
    return int.parse(value) > int.parse(other.value);
  }
}
