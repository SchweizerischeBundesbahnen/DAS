import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:ru_indications/component.dart';
import 'package:sfera/component.dart';

/// This class is used to combine foot note and other text annotations on the same service point.
/// This is needed to simplify the sticky behavior. Otherwise additional StickyLevels would be needed.
/// This is seen as a workaround and a more robust/extendable solution is needed.
class const CombinedFootNoteAndTextAnnotations({
  required super.order,
  required final List<JourneyAnnotation> textAnnotations,
  final BaseFootNote? footNote,
}) extends JourneyAnnotation {
  this : super(dataType: .combinedFootNoteAndTextAnnotations);

  @override
  OrderPriority get orderPriority => .operationalIndication;

  @override
  String toString() {
    return 'CombinedFootNoteAndTextAnnotations{footNote: $footNote, textAnnotations: $textAnnotations}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombinedFootNoteAndTextAnnotations &&
          runtimeType == other.runtimeType &&
          footNote == other.footNote &&
          ListEquality().equals(textAnnotations, other.textAnnotations);

  @override
  int get hashCode => Object.hash(footNote, textAnnotations);
}

extension CombineNotesAndIndicationsExtension on Iterable<BaseData> {
  /// Combines [BaseFootNote], [OperationalIndication], [RuIndication] and [PersonalNoteAnnotation] that are on same
  /// location (technically always on a service point)
  Iterable<BaseData> combineFootNoteAndTextAnnotations() {
    final groupedMap = where(
      (it) => it is BaseFootNote || it is OperationalIndication || it is RuIndication || it is PersonalNoteAnnotation,
    ).groupListsBy((i) => i.order);

    final dataToBeRemoved = <BaseData>[];
    final combinedData = groupedMap.values
        .map((group) {
          if (group.length < 2) {
            return null;
          }

          final footNote = group.firstWhereOrNull((it) => it is BaseFootNote) as BaseFootNote?;
          final textAnnotations = group.where((it) => it is! BaseFootNote).whereType<JourneyAnnotation>();
          final allData = [?footNote, ...textAnnotations];
          dataToBeRemoved.addAll(allData);

          return CombinedFootNoteAndTextAnnotations(
            footNote: footNote,
            textAnnotations: textAnnotations.toList(),
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
