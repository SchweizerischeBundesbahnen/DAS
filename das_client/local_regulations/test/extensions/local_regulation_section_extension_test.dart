import 'package:flutter_test/flutter_test.dart';
import 'package:local_regulations/src/extensions/local_regulation_section_extension.dart';
import 'package:sfera/component.dart';

void main() {
  test('toHtml_whenWithAbbreviation_thenRowTemplate', () {
    // ARRANGE
    final section = LocalRegulationSection(
      title: LocalizedString(de: 'R Profil EBV O2'),
      content: LocalizedString(de: '<div>This is a text</div>'),
    );

    // ACT & EXPECT
    final html = section.toHtml();
    expect(html, '''
      <div class="base-row">
        <div class="col-relevance">R</div>
        <div class="col-content">
          <div class="title">Profil EBV O2</div>
          <div><div>This is a text</div></div>
        </div>
      </div>
      ''');
  });
  test('toHtml_whenWithoutAbbreviation_thenStandardTemplate', () {
    // ARRANGE
    final section = LocalRegulationSection(
      title: LocalizedString(de: 'ZUE Zürich'),
      content: LocalizedString(de: '<div>This is a text</div>'),
    );

    // ACT & EXPECT
    final html = section.toHtml();
    expect(html, '''
      <h3>ZUE Zürich</h3>
      <div><div>This is a text</div></div>
      ''');
  });
}
