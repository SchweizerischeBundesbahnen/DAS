import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class EndDestinationChangeNspDto extends GeneralJpInformationNspDto {
  static const String groupNameValue = 'endDestinationChange';

  EndDestinationChangeNspDto({super.type, super.attributes, super.children, super.value});

  String get oldLocationCode => parameters.withName('oldLocation')!.nspValue;

  String get newLocationCode => parameters.withName('newLocation')!.nspValue;

  @override
  bool validate() {
    return super.validateHasParameterWithName('oldLocation') &&
        super.validateHasParameterWithName('newLocation') &&
        super.validate();
  }
}
