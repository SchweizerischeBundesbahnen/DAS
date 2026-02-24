import 'package:sfera/src/data/dto/change_dto.dart';

class TrainRunReroutingChangeDto extends ChangeDto {
  static const String _attributeSeparator = '-';

  TrainRunReroutingChangeDto({super.type, super.attributes, super.children, super.value});

  List<String> get oldRouteLocationCodes => attributes['oldRoute']?.split(_attributeSeparator) ?? [];

  List<String> get newRouteLocationCodes => attributes['newRoute']?.split(_attributeSeparator) ?? [];

  @override
  bool validate() {
    return super.validateHasAttribute('oldRoute') && super.validateHasAttribute('newRoute') && super.validate();
  }
}
