import 'package:sfera/src/data/dto/timing_point_constraints_nsp_dto.dart';
import 'package:sfera/src/data/parser/parse_utils.dart';

class PassingPointInformationNspDto extends TimingPointConstraintsNspDto {
  static const String groupNameValue = 'passingPointInformation';

  PassingPointInformationNspDto({super.type, super.attributes, super.children, super.value});

  DateTime? get plannedReleasedTime =>
      ParseUtils.tryParseDateTime(parameters.where((it) => it.name == 'plannedReleasedTime').firstOrNull?.nspValue);
}
