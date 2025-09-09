import 'dart:core';

import 'package:local_regulations/component.dart';
import 'package:local_regulations/src/extensions/local_regulation_section_extension.dart';
import 'package:local_regulations/src/template/css_style.dart';
import 'package:local_regulations/src/template/html_template.dart';
import 'package:sfera/component.dart';

const String _htmlTemplateString = '{{HTML_BODY}}';
const String _cssTemplateString = '{{CSS_STYLE}}';

class LocalRegulationHtmlGeneratorImpl implements LocalRegulationHtmlGenerator {
  @override
  String generate({required List<LocalRegulationSection> sections}) {
    return htmlTemplate.appendSections(sections).appendCSS();
  }
}

// extensions

extension _StringExtension on String {
  String appendCSS() => replaceAll(_cssTemplateString, cssStyle);

  String appendSections(List<LocalRegulationSection> sections) {
    final sectionsAsHtml = sections.map((section) => section.toHtml()).join();
    return replaceAll(_htmlTemplateString, sectionsAsHtml);
  }
}
