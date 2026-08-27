import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum StopPassChangeTypeDto({@override required final String xmlValue}) implements XmlEnum {
  stopToPass(xmlValue: 'stop2Pass'),
  passToStop(xmlValue: 'pass2Stop');
}
