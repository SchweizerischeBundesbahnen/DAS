import 'package:das_client/app/model/train_journey_settings.dart';
import 'package:das_client/model/journey/balise_level_crossing_group.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';

extension BaseDataExtension on List<BaseData> {
  List<BaseData> groupBaliseAndLeveLCrossings(TrainJourneySettings settings) {
    final List<BaseData> resultList = [];

    for (int i = 0; i < length; i++) {
      final currentElement = this[i];
      if (!currentElement.canGroup) {
        resultList.add(currentElement);
        continue;
      }

      final groupedElements = [currentElement];
      for (int j = i + 1; j < length; j++) {
        final nextElement = this[j];
        if (nextElement.canGroup && nextElement.canGroupWith(currentElement)) {
          groupedElements.add(nextElement);
        } else {
          break;
        }
      }

      if (groupedElements.length > 1 && [Datatype.balise, Datatype.levelCrossing].contains(currentElement.type)) {
        final group = BaliseLevelCrossingGroup(
            order: groupedElements[0].order, kilometre: groupedElements[0].kilometre, groupedElements: groupedElements);
        resultList.add(group);

        if (settings.expandedGroups.contains(group.order)) {
          resultList.addAll(groupedElements);
        }

        i += groupedElements.length - 1;
      } else {
        resultList.add(currentElement);
      }
    }

    return resultList;
  }
}
