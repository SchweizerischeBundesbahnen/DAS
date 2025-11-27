import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum GradientDirectionTypeDto implements XmlEnum {
  downhill(xmlValue: 'Downhill'),
  uphill(xmlValue: 'Uphill')
  ;

  const GradientDirectionTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
