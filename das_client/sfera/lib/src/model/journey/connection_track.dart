import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class ConnectionTrack extends JourneyPoint {
  const ConnectionTrack({required super.order, required super.kilometre, this.text})
    : super(type: Datatype.connectionTrack);

  final String? text;

  @override
  String toString() =>
      'ConnectionTrack('
      'order: $order'
      ', kilometre: $kilometre'
      ', text: $text'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionTrack &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          text == other.text;

  @override
  int get hashCode => order.hashCode ^ Object.hashAll(kilometre) ^ text.hashCode;
}
