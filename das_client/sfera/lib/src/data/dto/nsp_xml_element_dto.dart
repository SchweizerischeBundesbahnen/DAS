import 'package:logging/logging.dart';
import 'package:sfera/component.dart';

final _log = Logger('NspXmlElementDto');

mixin NspXmlElementDto<T extends SferaXmlElementDto> on SferaXmlElementDto {
  T? _element;

  T get element => _element ?? _generateElement();

  T _generateElement() {
    _element = SferaReplyParser.parse<T>(attributes['value']!, unescapeAttributes: true);
    return _element!;
  }

  @override
  bool validate() {
    if (_element == null) {
      try {
        _generateElement();
      } catch (e) {
        _log.severe(
          'Failed to parse nsp xml element of type $T (name: ${attributes['name']}, '
          'value length: ${attributes['value']?.length})',
          e,
        );
        return false;
      }
    }
    return validateIsNotNull(_element) && element.validate() && super.validate();
  }
}
