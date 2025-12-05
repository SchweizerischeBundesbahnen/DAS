import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/foot_note.dart';

enum SferaFootNoteTypeDto implements XmlEnum {
  trackSpeed(xmlValue: 'trackSpeed', footNoteType: .trackSpeed),
  decisiveGradientUp(xmlValue: 'decisiveGradientUp', footNoteType: .decisiveGradientUp),
  decisiveGradientDown(xmlValue: 'decisiveGradientDown', footNoteType: .decisiveGradientDown),
  contact(xmlValue: 'contact', footNoteType: .contact),
  networkType(xmlValue: 'networkType', footNoteType: .networkType),
  journey(xmlValue: 'journey', footNoteType: .journey)
  ;

  const SferaFootNoteTypeDto({
    required this.xmlValue,
    required this.footNoteType,
  });

  @override
  final String xmlValue;

  final FootNoteType footNoteType;
}
