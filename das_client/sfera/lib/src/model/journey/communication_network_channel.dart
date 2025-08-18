import 'package:sfera/component.dart';

class CommunicationNetworkChannel extends JourneyPoint {
  const CommunicationNetworkChannel({
    required super.order,
    required super.kilometre,
  }) : super(type: Datatype.networkCommunicationChannel);

  @override
  bool get canGroup => false;
}
