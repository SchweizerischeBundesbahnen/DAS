import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum OperationalIndicationTypeDto({@override required final String xmlValue}) implements XmlEnum {
  uncoded(xmlValue: 'uncoded'),
  occupiedEntry(xmlValue: 'occupiedEntry'),
  limitedUsableTrack(xmlValue: 'limitedUsableTrack'),
  dispatcherDepartureAuthorization(xmlValue: 'dispatcherDepartureAuthorization');
}
