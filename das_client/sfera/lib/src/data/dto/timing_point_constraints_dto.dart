import 'package:sfera/src/data/dto/enums/stop_skip_pass_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stopping_point_information_dto.dart';
import 'package:sfera/src/data/dto/timing_point_reference_dto.dart';

class TimingPointConstraintsDto extends SferaXmlElementDto {
  static const String elementType = 'TimingPointConstraints';

  TimingPointConstraintsDto({super.type = elementType, super.attributes, super.children, super.value});

  TimingPointReferenceDto get timingPointReference => children.whereType<TimingPointReferenceDto>().first;

  StoppingPointInformationDto? get stoppingPointInformation => children.whereType<StoppingPointInformationDto>().firstOrNull;

  StopSkipPassDto get stopSkipPass =>
      XmlEnum.valueOf<StopSkipPassDto>(StopSkipPassDto.values, attributes['TP_StopSkipPass']) ?? StopSkipPassDto.stoppingPoint;

  @override
  bool validate() {
    return validateHasChildOfType<TimingPointReferenceDto>() && super.validate();
  }
}
