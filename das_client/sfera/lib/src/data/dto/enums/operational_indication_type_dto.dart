import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum OperationalIndicationTypeDto implements XmlEnum {
  uncoded(xmlValue: 'uncoded'),
  occupiedEntry(xmlValue: 'occupiedEntry'),
  limitedUsableTrack(xmlValue: 'limitedUsableTrack'),
  dispatcherDepartureAuthorization(xmlValue: 'dispatcherDepartureAuthorization');

  const OperationalIndicationTypeDto({
    required this.xmlValue,
  });

  @override
  final String xmlValue;
}
