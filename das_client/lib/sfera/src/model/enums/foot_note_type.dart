import 'package:das_client/sfera/src/model/enums/xml_enum.dart';

enum FootNoteType implements XmlEnum {
  trackSpeed(xmlValue: 'trackSpeed'),
  decisiveGradientUp(xmlValue: 'decisiveGradientUp'),
  decisiveGradientDown(xmlValue: 'decisiveGradientDown'),
  contact(xmlValue: 'contact'),
  networkType(xmlValue: 'networkType'),
  journey(xmlValue: 'journey');

  const FootNoteType({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
