import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum GradientDirectionType implements XmlEnum {
  downhill(xmlValue: 'Downhill'),
  uphill(xmlValue: 'Uphill');

  const GradientDirectionType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
