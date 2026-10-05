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
  String generate({required Map<String, LocalRegulationSection> sectionMap, required String? rootId}) {
    final sections = <LocalRegulationSection>[];
    _buildOrderedSectionList(sections, sectionMap, rootId);

    return htmlTemplate.appendSections(sections).appendCSS();
  }

  void _buildOrderedSectionList(
    List<LocalRegulationSection> sections,
    Map<String, LocalRegulationSection> sectionMap,
    String? currentId,
  ) {
    final currentSection = sectionMap[currentId];
    if (currentSection == null) return;

    sections.add(currentSection);

    final children = currentSection.children;
    if (children != null) {
      final childSections = children.split(';');
      for (final child in childSections) {
        _buildOrderedSectionList(sections, sectionMap, child);
      }
    }
  }
}

extension _StringExtension on String {
  String appendCSS() => replaceAll(cssTemplateString, cssStyle);

  String appendSections(List<LocalRegulationSection> sections) {
    final sectionsAsHtml = sections.map((section) => section.toHtml()).join();
    return replaceAll(htmlTemplateString, sectionsAsHtml);
  }
}
