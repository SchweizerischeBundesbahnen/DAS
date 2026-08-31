import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum DasDrivingModeDto({@override required final String xmlValue}) implements XmlEnum {
  inactive(xmlValue: 'Inactive'),
  timetable(xmlValue: 'Timetable'),
  readOnly(xmlValue: 'Read-Only'),
  dasNotConnected(xmlValue: 'DAS not connected to ATP'),
  goa1(xmlValue: 'GoA1'),
  goa2(xmlValue: 'GoA2'),
  goa3(xmlValue: 'GoA3'),
  goa4(xmlValue: 'GoA4'),
}
