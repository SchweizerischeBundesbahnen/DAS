import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/model/journey/modification_type.dart';

enum ModificationTypeDto({
  @override required final String xmlValue,
  required final ModificationType modificationType,
}) implements XmlEnum {
  updated(xmlValue: 'updated', modificationType: .updated),
  deleted(xmlValue: 'deleted', modificationType: .deleted);
}
