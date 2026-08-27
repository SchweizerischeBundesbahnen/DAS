import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum GradientDirectionTypeDto({@override required final String xmlValue}) implements XmlEnum {
  downhill(xmlValue: 'Downhill'),
  uphill(xmlValue: 'Uphill');
}
