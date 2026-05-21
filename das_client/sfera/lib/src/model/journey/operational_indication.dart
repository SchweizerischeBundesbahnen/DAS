import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/model/journey/order_priority.dart';

class OperationalIndication extends JourneyAnnotation {
  const OperationalIndication({
    required super.order,
    required this.texts,
  }) : super(dataType: .operationalIndication);

  final List<String> texts;

  String get combinedText => texts.join('\n');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationalIndication &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(texts, other.texts) &&
          order == other.order;

  @override
  int get hashCode => Object.hash(dataType, order, const ListEquality().hash(texts));

  @override
  OrderPriority get orderPriority => .operationalIndication;

  @override
  String toString() {
    return 'OperationalIndication{order: $order, texts: $texts}';
  }
}

extension OperationalIndicationIterableExtension on Iterable<OperationalIndication> {
  Iterable<OperationalIndication> mergeOnSameLocation() =>
      groupFoldBy<int, OperationalIndication>((i) => i.order, (previous, next) {
        return OperationalIndication(
          order: next.order,
          texts: next.texts..addAll(previous?.texts ?? []),
        );
      }).values;
}
