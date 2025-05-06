import 'package:sfera/src/model/journey/communication_network_change.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum SferaCommunicationNetworkTypeDto implements XmlEnum {
  gsmR(xmlValue: 'GSM-R', communicationNetworkType: CommunicationNetworkType.gsmR),
  gsmP(xmlValue: 'GSM-P', communicationNetworkType: CommunicationNetworkType.gsmP),
  sim(xmlValue: 'SIM', communicationNetworkType: CommunicationNetworkType.sim);

  const SferaCommunicationNetworkTypeDto({
    required this.xmlValue,
    required this.communicationNetworkType,
  });

  @override
  final String xmlValue;

  final CommunicationNetworkType communicationNetworkType;
}
