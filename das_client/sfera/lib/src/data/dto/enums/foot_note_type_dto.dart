import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/foot_note.dart';

enum SferaFootNoteTypeDto implements XmlEnum {
  trackSpeed(xmlValue: 'trackSpeed', footNoteType: FootNoteType.trackSpeed),
  decisiveGradientUp(xmlValue: 'decisiveGradientUp', footNoteType: FootNoteType.decisiveGradientUp),
  decisiveGradientDown(xmlValue: 'decisiveGradientDown', footNoteType: FootNoteType.decisiveGradientDown),
  contact(xmlValue: 'contact', footNoteType: FootNoteType.contact),
  networkType(xmlValue: 'networkType', footNoteType: FootNoteType.networkType),
  journey(xmlValue: 'journey', footNoteType: FootNoteType.journey);

  const SferaFootNoteTypeDto({
    required this.xmlValue,
    required this.footNoteType,
  });

  @override
  final String xmlValue;

  final FootNoteType footNoteType;
}
