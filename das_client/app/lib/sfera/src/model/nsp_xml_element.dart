import 'package:app/sfera/sfera_component.dart';
import 'package:app/sfera/src/model/sfera_xml_element.dart';
import 'package:app/sfera/src/string_extension.dart';
import 'package:fimber/fimber.dart';

mixin NspXmlElement<T extends SferaXmlElement> on SferaXmlElement {
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
        Fimber.e(
            'Failed to parse nsp xml element of type ${T.runtimeType.toString()} with value ${attributes['value']}',
            ex: e);
        return false;
      }
    }
    return validateIsNotNull(_element) && element.validate() && super.validate();
  }
}
