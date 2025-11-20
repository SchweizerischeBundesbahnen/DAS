import 'dart:core';

import 'package:local_regulations/component.dart';
import 'package:local_regulations/src/extensions/local_regulation_section_extension.dart';
import 'package:local_regulations/src/template/css_style.dart';
import 'package:local_regulations/src/template/html_template.dart';
import 'package:sfera/component.dart';

const String htmlTemplateString = '{{HTML_BODY}}';
const String cssTemplateString = '{{CSS_STYLE}}';

class LocalRegulationHtmlGeneratorImpl implements LocalRegulationHtmlGenerator {
  @override
  String generate({required List<LocalRegulationSection> sections}) {
    return htmlTemplate.appendSections(sections).appendCSS();
  }
}

extension _StringExtension on String {
  String appendCSS() => replaceAll(cssTemplateString, cssStyle);

  String appendSections(List<LocalRegulationSection> sections) {
    final sectionsAsHtml = sections.map((section) => section.toHtml()).join();
    return replaceAll(htmlTemplateString, sectionsAsHtml);
  }
}
