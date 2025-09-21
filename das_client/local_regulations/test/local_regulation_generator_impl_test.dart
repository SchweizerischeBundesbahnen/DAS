import 'package:flutter_test/flutter_test.dart';
import 'package:local_regulations/src/local_regulation_generator_impl.dart';
import 'package:sfera/component.dart';

void main() {
  test('generate_expectReplacedHtmlAndCss', () {
    // ARRANGE
    final testee = LocalRegulationHtmlGeneratorImpl();
    final sections = [
      LocalRegulationSection(
        title: LocalizedString(de: 'Title A'),
        content: LocalizedString(de: 'Content A'),
      ),
      LocalRegulationSection(
        title: LocalizedString(de: 'Title B'),
        content: LocalizedString(de: 'Content B'),
      ),
    ];

    // ACT & EXPECT
    final html = testee.generate(sections: sections);
    expect(html.contains(htmlTemplateString), isFalse);
    expect(html.contains(cssTemplateString), isFalse);
    expect(html.contains('CSS FOR BASE STRUCTURE'), isTrue);
    expect(html.contains('CSS FOR LOCAL REGULATION HTML'), isTrue);
    expect(html.contains('Title A'), isTrue);
    expect(html.contains('Content A'), isTrue);
    expect(html.contains('Title B'), isTrue);
    expect(html.contains('Content B'), isTrue);
  });
}
