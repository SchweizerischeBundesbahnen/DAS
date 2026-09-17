import 'package:flutter_test/flutter_test.dart';
import 'package:local_regulations/src/local_regulation_generator_impl.dart';
import 'package:sfera/component.dart';

void main() {
  test('generate_expectReplacedHtmlAndCss', () {
    // ARRANGE
    final testee = LocalRegulationHtmlGeneratorImpl();
    final sections = {
      '1': LocalRegulationSection(
        id: '1',
        title: 'Title A',
        content: 'Content A',
        children: '2',
      ),
      '2': LocalRegulationSection(
        id: '2',
        title: 'Title B',
        content: 'Content B',
      ),
    };

    // ACT & EXPECT
    final html = testee.generate(sectionMap: sections, rootId: '1');
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
