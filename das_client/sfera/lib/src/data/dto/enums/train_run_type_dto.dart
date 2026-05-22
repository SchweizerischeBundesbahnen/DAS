import 'package:sfera/src/data/dto/enums/xml_enum.dart';

enum TrainRunTypeDto implements XmlEnum {
  shuntingOnOpenTrack(xmlValue: 'shuntingOnOpenTrack');

  const TrainRunTypeDto({required this.xmlValue});

  @override
  final String xmlValue;
}
