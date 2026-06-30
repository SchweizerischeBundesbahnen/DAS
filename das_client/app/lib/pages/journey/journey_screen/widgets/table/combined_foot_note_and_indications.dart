import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:ru_indications/component.dart';
import 'package:sfera/component.dart';

/// This class is used to combine foot notes and indications on the same service point.
/// This is needed to simplify the sticky behavior. Otherwise additional StickyLevels would be needed.
/// This is seen as a workaround and a more robust/extendable solution is needed.
class CombinedFootNoteAndIndications extends JourneyAnnotation {
  CombinedFootNoteAndIndications({
    required this.footNote,
    required this.indications,
  }) : super(dataType: .combinedFootNoteAndIndications, order: footNote.order);

  final BaseFootNote footNote;
  final List<JourneyAnnotation> indications;

  // TODO: Which oder priority?
  @override
  OrderPriority get orderPriority => .operationalIndication;

  @override
  String toString() {
    return 'CombinedFootNoteAndIndications{footNote: $footNote, indications: $indications}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombinedFootNoteAndIndications &&
          runtimeType == other.runtimeType &&
          footNote == other.footNote &&
          ListEquality().equals(indications, other.indications);

  @override
  int get hashCode => Object.hash(footNote, indications);
}

extension CombineFootNoteAndIndicationsExtension on Iterable<BaseData> {
  /// Combines [BaseFootNote], [OperationalIndication] and [RuIndication] that are on same location (technically always on a service point)
  Iterable<BaseData> combineFootNoteAndIndications() {
    final groupedMap = where(
      (it) => it is BaseFootNote || it is OperationalIndication || it is RuIndication,
    ).groupListsBy((i) => i.order);

    final dataToBeRemoved = <BaseData>[];
    final combinedData = groupedMap.values
        .map((group) {
          final footNote = group.firstWhereOrNull((it) => it is BaseFootNote) as BaseFootNote?;
          final operationalIndication =
              group.firstWhereOrNull((it) => it is OperationalIndication) as OperationalIndication?;
          final ruIndications = group.whereType<RuIndication>();
          if (footNote == null || (operationalIndication == null && ruIndications.isEmpty)) {
            return null;
          }

          final indications = [operationalIndication, ...ruIndications].nonNulls;
          dataToBeRemoved.addAll([footNote, ...indications]);
          return CombinedFootNoteAndIndications(footNote: footNote, indications: indications.toList());
        })
        .nonNulls
        .toList(); // force non-lazy map

    return List.of(this)
      ..removeWhere((it) => dataToBeRemoved.contains(it))
      ..addAll(combinedData);
  }
}
