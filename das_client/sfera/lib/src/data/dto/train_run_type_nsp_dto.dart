import 'package:sfera/src/data/dto/enums/train_run_type_dto.dart';
import 'package:sfera/src/data/dto/enums/xml_enum.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class TrainRunTypeNspDto({super.type, super.attributes, super.children, super.value})
    extends NetworkSpecificParameterDto {
  static const String elementName = 'trainRunType';

  TrainRunTypeDto get trainRunType => XmlEnum.valueOf<TrainRunTypeDto>(TrainRunTypeDto.values, nspValue)!;

  @override
  bool validate() => validateHasAttributeInRange('value', XmlEnum.values(TrainRunTypeDto.values)) && super.validate();
}
