import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';
import 'package:sfera/src/data/dto/stop_pass_change_dto.dart';
import 'package:sfera/src/data/dto/train_run_rerouting_change_dto.dart';

abstract class ChangeDto extends SferaXmlElementDto {
  static const String elementType = 'change';

  ChangeDto({super.type = elementType, super.attributes, super.children, super.value});

  factory ChangeDto.from({
    Map<String, String>? attributes,
    List<SferaXmlElementDto>? children,
    String? value,
  }) {
    final hasModifiedOp = attributes?['modifiedOP']?.isNotEmpty ?? false;
    if (hasModifiedOp) {
      return StopPassChangeDto(attributes: attributes, children: children, value: value);
    } else {
      return TrainRunReroutingChangeDto(attributes: attributes, children: children, value: value);
    }
  }
}
