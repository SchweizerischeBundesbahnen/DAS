import 'package:collection/collection.dart';
import 'package:ru_indications/src/model/ru_indication_content.dart';

class RuIndication {
  const RuIndication({
    required this.tafTapLocationReference,
    required this.ruIndicationContents,
  });

  final String tafTapLocationReference;
  final List<RuIndicationContent> ruIndicationContents;

  @override
  String toString() {
    return 'RuIndication{tafTapLocationReference: $tafTapLocationReference, ruIndicationContents: $ruIndicationContents}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuIndication &&
          runtimeType == other.runtimeType &&
          tafTapLocationReference == other.tafTapLocationReference &&
          ListEquality().equals(ruIndicationContents, other.ruIndicationContents);

  @override
  int get hashCode => Object.hash(tafTapLocationReference, ruIndicationContents);
}
