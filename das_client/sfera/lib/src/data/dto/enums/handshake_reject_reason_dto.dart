import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum HandshakeRejectReasonDto({@override required final String xmlValue}) implements XmlEnum {
  atoVersionIncompatible(xmlValue: 'ATO system version incompatible'),
  sferaVersionIncompatible(xmlValue: 'SFERA version incompatible'),
  anotherDasAtoInCharge(xmlValue: 'Another DAS-TS/ATO-TS in charge'),
  dasInChargeUnknown(xmlValue: 'DAS-TS/ATO-TS in charge unknown'),
  architectureNotSupported(xmlValue: 'Architecture not supported'),
  connectivityNotSupported(xmlValue: 'Connectivity not supported'),
  archAndConnNotSupported(xmlValue: 'Architecture and connectivity not supported');
}
