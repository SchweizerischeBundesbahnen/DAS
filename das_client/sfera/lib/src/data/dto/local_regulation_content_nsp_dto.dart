import 'package:core_data/component.dart';
import 'package:sfera/src/data/dto/network_specific_parameter_dto.dart';

class LocalRegulationContentNspDto extends NetworkSpecificParameterDto {
  static bool matchesElementName(String name) => RegExp(r'^content(De|Fr|It)$').hasMatch(name);

  LocalRegulationContentNspDto({super.attributes, super.children, super.value});
}

extension LocalRegulationContentNspDtoIterableX on Iterable<LocalRegulationContentNspDto> {
  String? textFor(String locale) => where((it) => it.name.toLowerCase().endsWith(locale)).firstOrNull?.nspValue;

  LocalizedString get toLocalizedString {
    return LocalizedString(
      de: textFor('de'),
      fr: textFor('fr'),
      it: textFor('it'),
    );
  }
}
