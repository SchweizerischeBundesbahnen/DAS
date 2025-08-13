import 'package:sfera/component.dart';

class ConnectionTrack extends JourneyPoint {
  const ConnectionTrack({required super.order, required super.kilometre, this.text})
    : super(type: Datatype.connectionTrack);

  final String? text;

  @override
  String toString() {
    return 'ConnectionTrack(text: $text)';
  }
}
