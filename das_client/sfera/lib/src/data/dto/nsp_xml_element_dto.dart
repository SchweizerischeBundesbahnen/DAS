import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/sfera_xml_element_dto.dart';

final _log = Logger('NspXmlElementDto');

mixin NspXmlElementDto<T extends SferaXmlElementDto> on SferaXmlElementDto {
  T? _element;

  T get element => _element ?? _generateElement();

  T _generateElement() {
    _element = SferaReplyParser.parse<T>(attributes['value'].unescapedString!);
    return _element!;
  }

  @override
  bool validate() {
    if (_element == null) {
      try {
        _generateElement();
      } catch (e) {
        _log.severe(
          'Failed to parse nsp xml element of type ${T.runtimeType.toString()} with value ${attributes['value']}',
          e,
        );
        return false;
      }
    }
    return validateIsNotNull(_element) && element.validate() && super.validate();
  }
}

// extensions

extension _XmlNullableStringExtension on String? {
  String? get unescapedString {
    return this?.unescapedString ?? this;
  }
}

extension _XmlStringExtension on String {
  String get unescapedString {
    return replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&apos;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('<br>', '<br/>');
  }
}
