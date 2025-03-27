import 'package:das_client/model/journey/balise_level_crossing_group.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/line_foot_note.dart';
import 'package:das_client/model/journey/metadata.dart';

extension BaseDataExtension on Iterable<BaseData> {
  List<BaseData> groupBaliseAndLeveLCrossings(List<int> expandedGroups) {
    final List<BaseData> resultList = [];

    for (int i = 0; i < length; i++) {
      final currentElement = elementAt(i);
      if (!currentElement.canGroup) {
        // Just add elements to the result that are unable to be grouped
        resultList.add(currentElement);
        continue;
      }

      final groupedElements = [currentElement];
      // check the next elements if they can be grouped with the currentElement.
      for (int j = i + 1; j < length; j++) {
        final nextElement = elementAt(j);
        if (nextElement.canGroup && currentElement.canGroupWith(nextElement)) {
          groupedElements.add(nextElement);
        } else {
          // Stop once we reach a element that is unable to be grouped
          break;
        }
      }

      if (groupedElements.length > 1 && [Datatype.balise, Datatype.levelCrossing].contains(currentElement.type)) {
        // Add a group header if we have more then 1 element
        final group = BaliseLevelCrossingGroup(
            order: groupedElements[0].order, kilometre: groupedElements[0].kilometre, groupedElements: groupedElements);
        resultList.add(group);

        // Add all the elements if the group is currently expanded
        if (expandedGroups.contains(group.order)) {
          resultList.addAll(groupedElements);
        }

        // skip already checked elements
        i += groupedElements.length - 1;
      } else {
        resultList.add(currentElement);
      }
    }

    return resultList;
  }

  List<BaseData> hideRepeatedLineFootNotes(Metadata metadata) {
    final resultList = List.of(this);

    final currentPositionIndex = resultList.indexOf(metadata.currentPosition ?? resultList.first);
    final displayedFootNoteIdentifiers = [];

    for (int i = currentPositionIndex; i < resultList.length; i++) {
      final currentElement = resultList[i];
      if (currentElement.type == Datatype.lineFootNote) {
        final lineFootNote = currentElement as LineFootNote;
        if (displayedFootNoteIdentifiers.contains(lineFootNote.identifier)) {
          resultList.removeAt(i);
          i--;
        } else {
          displayedFootNoteIdentifiers.add(lineFootNote.identifier);
        }
      }
    }

    for (int i = currentPositionIndex; i >= 0; i--) {
      final currentElement = resultList[i];
      if (currentElement.type == Datatype.lineFootNote) {
        final lineFootNote = currentElement as LineFootNote;
        if (displayedFootNoteIdentifiers.contains(lineFootNote.identifier)) {
          resultList.removeAt(i);
        } else {
          displayedFootNoteIdentifiers.add(lineFootNote.identifier);
        }
      }
    }

    return resultList;
  }
}
