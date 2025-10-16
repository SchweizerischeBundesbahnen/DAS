import 'package:sfera/component.dart';

extension JourneyPointListExtension on List<JourneyPoint> {
  int indexOfElementOrGroup(JourneyPoint point, List<int> expandedGroups) {
    for (int i = 0; i < length; i++) {
      final current = this[i];
      if (current == point) {
        return i;
      } else if (current is GroupedJourneyPoint) {
        final isExpanded = expandedGroups.contains(current.order);
        if (!isExpanded && current.groupedElements.contains(point)) {
          return i;
        }
      }
    }
    return -1;
  }
}
