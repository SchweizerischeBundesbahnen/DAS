import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum StartEndQualifier implements XmlEnum {
  starts(xmlValue: 'Starts'),
  ends(xmlValue: 'Ends'),
  startsEnds(xmlValue: 'StartsEnds'),
  wholeSp(xmlValue: 'WholeSP');

  const StartEndQualifier({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
