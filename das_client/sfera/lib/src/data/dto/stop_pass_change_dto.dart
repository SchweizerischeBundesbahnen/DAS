import 'package:sfera/src/data/dto/change_dto.dart';
import 'package:sfera/src/data/dto/enums/stop_pass_change_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';

class StopPassChangeDto extends ChangeDto {
  StopPassChangeDto({super.type, super.attributes, super.children, super.value});

  StopPassChangeTypeDto get changeType => XmlEnum.valueOf(StopPassChangeTypeDto.values, attributes['changeType'])!;

  String get modifiedOPLocationCode => attributes['modifiedOP']!;

  @override
  bool validate() {
    return super.validateHasAttribute('changeType') && super.validateHasAttribute('modifiedOP') && super.validate();
  }
}
