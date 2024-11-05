import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum HandshakeRejectReason implements XmlEnum {
  atoVersionIncompatible(xmlValue: 'ATO system version incompatible'),
  sferaVersionIncompatible(xmlValue: 'SFERA version incompatible'),
  anotherDasAtoInCharge(xmlValue: 'Another DAS-TS/ATO-TS in charge'),
  dasInChargeUnkown(xmlValue: 'DAS-TS/ATO-TS in charge unknown'),
  architectureNotSupported(xmlValue: 'Architecture not supported'),
  connectivityNotSupported(xmlValue: 'Connectivity not supported'),
  archAndConnNotSupported(xmlValue: 'Architecture and connectivity not supported');

  const HandshakeRejectReason({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
