import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:ru_indications/component.dart';
import 'package:sfera/component.dart';

/// This class is used to combine foot notes and indications on the same service point.
/// This is needed to simplify the sticky behavior. Otherwise additional StickyLevels would be needed.
/// This is seen as a workaround and a more robust/extendable solution is needed.
class CombinedFootNoteAndIndications extends JourneyAnnotation {
  const CombinedFootNoteAndIndications({
    required this.indications,
    required super.order,
    this.footNote,
  }) : super(dataType: .combinedFootNoteAndIndications);

  final BaseFootNote? footNote;
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
          if (group.length < 2) {
            return null;
          }

          final footNote = group.firstWhereOrNull((it) => it is BaseFootNote) as BaseFootNote?;
          final indications = group.where((it) => it is! BaseFootNote).whereType<JourneyAnnotation>();
          final allData = [?footNote, ...indications];
          dataToBeRemoved.addAll(allData);

          return CombinedFootNoteAndIndications(
            footNote: footNote,
            indications: indications.toList(),
            order: allData.first.order,
          );
        })
        .nonNulls
        .toList(); // force non-lazy map

    return List.of(this)
      ..removeWhere((it) => dataToBeRemoved.contains(it))
      ..addAll(combinedData);
  }
}
