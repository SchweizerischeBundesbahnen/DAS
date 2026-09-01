import 'package:sfera/src/data/dto/change_dto.dart';

class TrainRunReroutingChangeDto({super.type, super.attributes, super.children, super.value}) extends ChangeDto {
  static const String _attributeSeparator = '-';

  List<String> get oldRouteLocationCodes => attributes['oldRoute']?.split(_attributeSeparator) ?? [];

  List<String> get newRouteLocationCodes => attributes['newRoute']?.split(_attributeSeparator) ?? [];

  @override
  bool validate() {
    return super.validateHasAttribute('oldRoute') && super.validateHasAttribute('newRoute') && super.validate();
  }
}
