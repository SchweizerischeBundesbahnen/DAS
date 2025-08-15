import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

extension BaseDataExtension on Iterable<BaseData> {
  Iterable<BaseData> groupBaliseAndLeveLCrossings(List<int> expandedGroups) {
    final List<BaseData> resultList = [];

    for (int i = 0; i < length; i++) {
      final currentElement = elementAt(i);
      if (!currentElement.canGroup || currentElement is! JourneyPoint) {
        // Just add elements to the result that are unable to be grouped
        resultList.add(currentElement);
        continue;
      }

      final groupedElements = <JourneyPoint>[currentElement];
      // check the next elements if they can be grouped with the currentElement.
      for (int j = i + 1; j < length; j++) {
        final nextElement = elementAt(j);
        if (nextElement.canGroup && currentElement.canGroupWith(nextElement) && nextElement is JourneyPoint) {
          groupedElements.add(nextElement);
        } else {
          // Stop once we reach a element that is unable to be grouped
          break;
        }
      }

      if (groupedElements.length > 1 && [Datatype.balise, Datatype.levelCrossing].contains(currentElement.type)) {
        // Add a group header if we have more then 1 element
        final group = BaliseLevelCrossingGroup(
          order: groupedElements[0].order,
          kilometre: groupedElements[0].kilometre,
          groupedElements: groupedElements,
        );
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

  Iterable<BaseData> hideRepeatedLineFootNotes(BaseData? position) {
    final resultList = List.of(this);

    final currentPosition = position ?? resultList.first;
    final displayedFootNoteIdentifiers = [];

    var currentPositionIndex = resultList.indexOf(currentPosition);

    // Current position lineFootNotes have priority
    resultList
        .where((it) => it.order == currentPosition.order)
        .whereType<LineFootNote>()
        .forEach((it) => displayedFootNoteIdentifiers.add(it.identifier));

    // Search upwards
    currentPositionIndex = resultList.lastIndexWhere((it) => it.order < currentPosition.order);
    for (int i = currentPositionIndex; i >= 0; i--) {
      final currentElement = resultList[i];
      if (currentElement is LineFootNote) {
        if (displayedFootNoteIdentifiers.contains(currentElement.identifier)) {
          resultList.removeAt(i);
        } else {
          displayedFootNoteIdentifiers.add(currentElement.identifier);
        }
      }
    }

    // Search downwards starting from the next element with higher order
    currentPositionIndex = resultList.indexWhere((it) => it.order > currentPosition.order);
    if (currentPositionIndex != -1) {
      for (int i = currentPositionIndex; i < resultList.length; i++) {
        final currentElement = resultList[i];

        if (currentElement is LineFootNote) {
          if (displayedFootNoteIdentifiers.contains(currentElement.identifier)) {
            resultList.removeAt(i);
            i--;
          } else {
            displayedFootNoteIdentifiers.add(currentElement.identifier);
          }
        }
      }
    }

    return resultList;
  }

  Iterable<BaseData> hideFootNotesForNotSelectedTrainSeries(TrainSeries? selectedTrainSeries) {
    if (selectedTrainSeries == null) return this;

    return List.of(this)..removeWhere(
      (it) =>
          it is BaseFootNote &&
          it.footNote.trainSeries.isNotEmpty &&
          !it.footNote.trainSeries.contains(selectedTrainSeries),
    );
  }

  /// Combines [BaseFootNote] and [UncodedOperationalIndication] that are on same location (technically always on a service point)
  Iterable<BaseData> combineFootNoteAndOperationalIndication() {
    final groupedMap = where(
      (it) => it is BaseFootNote || it is UncodedOperationalIndication,
    ).groupListsBy((i) => i.order);

    final dataToBeRemoved = <BaseData>[];
    final combinedData = groupedMap.values
        .map((group) {
          final footNote = group.firstWhereOrNull((it) => it is BaseFootNote) as BaseFootNote?;
          final operationalIndication =
              group.firstWhereOrNull((it) => it is UncodedOperationalIndication) as UncodedOperationalIndication?;
          if (footNote == null || operationalIndication == null) {
            return null;
          }

          dataToBeRemoved.addAll([footNote, operationalIndication]);
          return CombinedFootNoteOperationalIndication(
            footNote: footNote,
            operationalIndication: operationalIndication,
          );
        })
        .nonNulls
        .toList(); // force non-lazy map

    return List.of(this)
      ..removeWhere((it) => dataToBeRemoved.contains(it))
      ..addAll(combinedData);
  }
}
