import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum StopPassChangeTypeDto implements XmlEnum {
  stop2Pass(xmlValue: 'stop2Pass'),
  pass2Stop(xmlValue: 'pass2Stop'),
  ;

  const StopPassChangeTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
