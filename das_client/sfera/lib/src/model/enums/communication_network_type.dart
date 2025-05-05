import 'package:app/model/journey/communication_network_change.dart';
import 'package:sfera/src/model/enums/xml_enum.dart';

enum SferaCommunicationNetworkType implements XmlEnum {
  gsmR(xmlValue: 'GSM-R', communicationNetworkType: CommunicationNetworkType.gsmR),
  gsmP(xmlValue: 'GSM-P', communicationNetworkType: CommunicationNetworkType.gsmP),
  sim(xmlValue: 'SIM', communicationNetworkType: CommunicationNetworkType.sim);

  const SferaCommunicationNetworkType({
    required this.xmlValue,
    required this.communicationNetworkType,
  });

  @override
  final String xmlValue;

  final CommunicationNetworkType communicationNetworkType;
}
