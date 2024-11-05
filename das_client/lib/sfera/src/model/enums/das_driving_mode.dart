import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum DasDrivingMode implements XmlEnum {
  inactive(xmlValue: 'Inactive'),
  timetable(xmlValue: 'Timetable'),
  readOnly(xmlValue: 'Read-Only'),
  dasNotConnected(xmlValue: 'DAS not connected to ATP'),
  goa1(xmlValue: 'GoA1'),
  goa2(xmlValue: 'GoA2'),
  goa3(xmlValue: 'GoA3'),
  goa4(xmlValue: 'GoA4');

  const DasDrivingMode({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
