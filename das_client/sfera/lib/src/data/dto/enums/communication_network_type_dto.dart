import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/communication_network_change.dart';

enum SferaCommunicationNetworkTypeDto implements XmlEnum {
  gsmR(xmlValue: 'GSM-R', communicationNetworkType: .gsmR),
  gsmP(xmlValue: 'GSM-P', communicationNetworkType: .gsmP),
  sim(xmlValue: 'SIM', communicationNetworkType: .sim)
  ;

  const SferaCommunicationNetworkTypeDto({
    required this.xmlValue,
    required this.communicationNetworkType,
  });

  @override
  final String xmlValue;

  final CommunicationNetworkType communicationNetworkType;
}
