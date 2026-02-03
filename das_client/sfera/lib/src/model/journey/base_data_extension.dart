import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

extension BaseDataExtension on Iterable<BaseData> {
  Iterable<BaseData> groupBaliseAndLevelCrossings(List<int> expandedGroups, Metadata metadata) {
    final List<BaseData> resultList = toList();

    final baliseGroups = <SupervisedLevelCrossingGroup>[];

    void addBaliseLevelCrossingGroup() {
      final groupedElements = <JourneyPoint>[];
      for (final baliseGroup in baliseGroups) {
        groupedElements.add(baliseGroup.balise);

        final servicePoint = baliseGroup.pointsBetween.firstWhereOrNull((it) => it is ServicePoint);

        for (final levelCrossing in baliseGroup.levelCrossings) {
          // Adjust order of level crossing if it is before the service point or if there is no service point
          if (servicePoint == null || servicePoint.order > levelCrossing.order) {
            final adjustedLevelCrossing = levelCrossing.copyWith(order: baliseGroup.balise.order);
            resultList.remove(levelCrossing);
            resultList.add(adjustedLevelCrossing);
            groupedElements.add(adjustedLevelCrossing);
          }
        }
      }

      // No grouping if only one element
      if (groupedElements.length <= 1) {
        baliseGroups.clear();
        return;
      }

      final group = BaliseLevelCrossingGroup(
        order: baliseGroups.first.balise.order,
        kilometre: baliseGroups.first.balise.kilometre,
        groupedElements: groupedElements,
      );
      resultList.add(group);
      baliseGroups.clear();

      // Remove elements if not expanded
      if (!expandedGroups.contains(group.order)) {
        for (final element in group.groupedElements) {
          resultList.remove(element);
        }
      }
    }

    for (final group in metadata.levelCrossingGroups) {
      if (group is SupervisedLevelCrossingGroup) {
        if (baliseGroups.isEmpty) {
          baliseGroups.add(group);
        } else {
          final previousBaliseGroup = baliseGroups.last;

          if (!previousBaliseGroup.canGroupWith(group) ||
              resultList.indexOf(previousBaliseGroup.levelCrossings.last) + 1 != resultList.indexOf(group.balise)) {
            // Finish group, if we can't group with the previous, or are not directly after
            addBaliseLevelCrossingGroup();
          }

          baliseGroups.add(group);
        }
      } else {
        _handleLevelCrossingGroups(resultList, expandedGroups, group);
      }
    }

    if (baliseGroups.isNotEmpty) {
      addBaliseLevelCrossingGroup();
    }

    resultList.sort();
    return resultList;
  }

  void _handleLevelCrossingGroups(List<BaseData> resultList, List<int> expandedGroups, LevelCrossingGroup group) {
    final firstLevelCrossing = group.levelCrossings[0];

    // Add group header
    resultList.add(
      BaliseLevelCrossingGroup(
        order: firstLevelCrossing.order,
        kilometre: firstLevelCrossing.kilometre,
        groupedElements: group.levelCrossings,
      ),
    );

    // Remove elements if not expanded
    if (!expandedGroups.contains(firstLevelCrossing.order)) {
      for (final levelCrossing in group.levelCrossings) {
        resultList.remove(levelCrossing);
      }
    }
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

  Iterable<BaseData> hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint() {
    final List<BaseData> resultList = toList();
    CommunicationNetworkChange? previousChange;
    for (final data in this) {
      if (data is CommunicationNetworkChange) {
        if (previousChange != null && previousChange.communicationNetworkType == data.communicationNetworkType) {
          resultList.remove(data);
        } else if (data.isServicePoint) {
          resultList.remove(data);
        }
        previousChange = data;
      }
    }

    return resultList;
  }

  Iterable<BaseData> hideJourneyPointThatShouldNotBeDisplayed() {
    final List<BaseData> resultList = toList();
    for (final data in this) {
      if (data is JourneyPoint && data.shouldHide) {
        resultList.remove(data);
      }
    }

    return resultList;
  }
}
