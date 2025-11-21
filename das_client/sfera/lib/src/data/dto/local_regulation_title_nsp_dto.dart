import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';
import 'package:sfera/src/model/localized_string.dart';

class LocalRegulationTitleNspDto extends NetworkSpecificParameterDto {
  static bool matchesElementName(String name) => RegExp(r'^title_(de|fr|it)$').hasMatch(name);

  LocalRegulationTitleNspDto({super.attributes, super.children, super.value});
}

extension LocalRegulationTitleNspDtoIterableX on Iterable<LocalRegulationTitleNspDto> {
  String? textFor(String locale) => where((it) => it.name.toLowerCase().endsWith(locale)).firstOrNull?.nspValue;

  LocalizedString get toLocalizedString {
    return LocalizedString(
      de: textFor('de'),
      fr: textFor('fr'),
      it: textFor('it'),
    );
  }
}
