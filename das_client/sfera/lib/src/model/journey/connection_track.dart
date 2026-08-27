import 'package:collection/collection.dart';
import 'package:sfera/component.dart';

class const ConnectionTrack({required super.order, required super.kilometre, final String? text}) extends JourneyPoint {
  this : super(dataType: .connectionTrack);

  @override
  String toString() {
    return 'ConnectionTrack{order: $order, kilometre: $kilometre, text: $text}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionTrack &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          ListEquality().equals(kilometre, other.kilometre) &&
          text == other.text;

  @override
  int get hashCode => dataType.hashCode ^ order.hashCode ^ Object.hashAll(kilometre) ^ text.hashCode;
}
