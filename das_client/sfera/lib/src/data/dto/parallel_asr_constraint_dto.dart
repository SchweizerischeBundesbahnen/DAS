import 'package:sfera/src/data/dto/id_nsp_dto.dart';
import 'package:sfera/src/data/dto/network_specific_constraint_dto.dart';
import 'package:sfera/src/data/dto/speed_nsp_dto.dart';

class ParallelAsrConstraintDto extends NetworkSpecificConstraintDto {
  static const String groupNameValue = 'parallel_ASR';

  ParallelAsrConstraintDto({super.type = groupNameValue, super.attributes, super.children, super.value});

  IdNetworkSpecificParameterDto get idNsp => parameters.whereType<IdNetworkSpecificParameterDto>().first;

  SpeedNetworkSpecificParameterDto get speedNsp => parameters.whereType<SpeedNetworkSpecificParameterDto>().first;

  @override
  bool validate() {
    return validateHasChildOfType<IdNetworkSpecificParameterDto>() &&
        validateHasChildOfType<SpeedNetworkSpecificParameterDto>() &&
        super.validate();
  }
}
