import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class EndDestinationChangeNspDto({super.type, super.attributes, super.children, super.value})
    extends GeneralJpInformationNspDto {
  static const String groupNameValue = 'endDestinationChange';

  String get oldLocationCode => parameters.withName('oldLocation')!.nspValue;

  String get newLocationCode => parameters.withName('newLocation')!.nspValue;

  @override
  bool validate() {
    return super.validateHasParameterWithName('oldLocation') &&
        super.validateHasParameterWithName('newLocation') &&
        super.validate();
  }
}
