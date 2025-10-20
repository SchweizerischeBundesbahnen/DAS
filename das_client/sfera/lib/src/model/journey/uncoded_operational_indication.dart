import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class UncodedOperationalIndication extends JourneyAnnotation {
  const UncodedOperationalIndication({
    required super.order,
    required this.texts,
  }) : super(type: Datatype.uncodedOperationalIndication);

  final List<String> texts;

  String get combinedText => texts.join('\n');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UncodedOperationalIndication &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(texts, other.texts) &&
          order == other.order;

  @override
  int get hashCode => Object.hash(type, order, const ListEquality().hash(texts));

  @override
  OrderPriority get orderPriority => OrderPriority.uncodedOperationalIndication;
}

// extensions

extension UncodedOperationalIndicationIterableExtension on Iterable<UncodedOperationalIndication> {
  Iterable<UncodedOperationalIndication> mergeOnSameLocation() =>
      groupFoldBy<int, UncodedOperationalIndication>((i) => i.order, (previous, next) {
        return UncodedOperationalIndication(
          order: next.order,
          texts: next.texts..addAll(previous?.texts ?? []),
        );
      }).values;
}
