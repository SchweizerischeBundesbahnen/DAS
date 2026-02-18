import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum StopPassChangeTypeDto implements XmlEnum {
  stopToPass(xmlValue: 'stop2Pass'),
  passToStop(xmlValue: 'pass2Stop'),
  ;

  const StopPassChangeTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
