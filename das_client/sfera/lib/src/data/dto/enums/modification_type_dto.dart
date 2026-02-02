import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/modification_type.dart';

enum ModificationTypeDto implements XmlEnum {
  updated(xmlValue: 'trackSpeed', modificationType: .updated),
  deleted(xmlValue: 'decisiveGradientUp', modificationType: .deleted),
  ;

  const ModificationTypeDto({
    required this.xmlValue,
    required this.modificationType,
  });

  @override
  final String xmlValue;

  final ModificationType modificationType;
}
