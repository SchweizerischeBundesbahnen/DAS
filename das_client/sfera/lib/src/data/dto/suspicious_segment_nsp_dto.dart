import 'package:sfera/src/data/dto/general_jp_information_nsp_dto.dart';

class SuspiciousSegmentNspDto extends GeneralJpInformationNspDto {
  static const String groupNameValue = 'suspiciousSPs';

  SuspiciousSegmentNspDto({super.type, super.attributes, super.children, super.value});

  /// Returns all SP_ID values listed in this NSP group.
  Iterable<String> get suspiciousSpIds => parameters.where((it) => it.name == 'SP_ID').map((it) => it.nspValue);

  @override
  bool validate() {
    return super.validateHasParameterWithName('SP_ID') && super.validate();
  }
}
