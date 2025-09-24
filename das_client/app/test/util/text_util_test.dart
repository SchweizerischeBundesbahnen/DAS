import 'package:app/util/text_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

void main() {
  test('textUtil_balanceHtmlTags_singleOpenTag', () {
    // GIVEN
    final input = '<b>A';
    final expectedOutput = '$input</b>';

    // WHEN
    final result = TextUtil.balanceHtmlTags(input);

    // THEN
    expect(result, expectedOutput);
  });

  test('textUtil_balanceHtmlTags_multipleOpenTag', () {
    // GIVEN
    final input = '<b><i>A';
    final expectedOutput = '$input</i></b>';

    // WHEN
    final result = TextUtil.balanceHtmlTags(input);

    // THEN
    expect(result, expectedOutput);
  });

  test('textUtil_balanceHtmlTags_noOpenTag', () {
    // GIVEN
    final input = '<b><i>A</i></b>';

    // WHEN
    final result = TextUtil.balanceHtmlTags(input);

    // THEN
    expect(result, input);
  });

  test('textUtil_balanceHtmlTags_someOpenTag', () {
    // GIVEN
    final input = '<b><i>A</i>';
    final expectedOutput = '$input</b>';

    // WHEN
    final result = TextUtil.balanceHtmlTags(input);

    // THEN
    expect(result, expectedOutput);
  });

  test('textUtil_balanceHtmlTags_multipleSplitOpenTag', () {
    // GIVEN
    final input = '<b><i>A</i><b>';
    final expectedOutput = '$input</b></b>';

    // WHEN
    final result = TextUtil.balanceHtmlTags(input);

    // THEN
    expect(result, expectedOutput);
  });

  test('textUtil_replaceHtmlLineBreaks', () {
    // GIVEN
    final input = '<br><br /><br >';
    final expectedOutput = '\n\n\n';

    // WHEN
    final result = TextUtil.replaceHtmlLineBreaks(input);

    // THEN
    expect(result, expectedOutput);
  });

  test('textUtil_parseHtmlText_italic', () {
    // GIVEN
    final input = 'Renens - Lausanne <i>via saut-de-mouton</i>';

    // WHEN
    final result = TextUtil.parseHtmlText(input, DASTextStyles.smallRoman);

    // THEN
    expect((result.children![0] as TextSpan).text, 'Renens - Lausanne ');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).text, 'via saut-de-mouton');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).style, DASTextStyles.smallRoman.italic);
  });

  test('textUtil_parseHtmlText_bold', () {
    // GIVEN
    final input = 'Renens - Lausanne <b>via saut-de-mouton</b>';

    // WHEN
    final result = TextUtil.parseHtmlText(input, DASTextStyles.smallRoman);

    // THEN
    expect((result.children![0] as TextSpan).text, 'Renens - Lausanne ');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).text, 'via saut-de-mouton');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).style, DASTextStyles.smallRoman.boldStyle);
  });

  test('textUtil_parseHtmlText_bold_italic', () {
    // GIVEN
    final input = 'Renens - Lausanne <i><b>via saut-de-mouton</b></i>';

    // WHEN
    final result = TextUtil.parseHtmlText(input, DASTextStyles.smallRoman);

    // THEN
    expect((result.children![0] as TextSpan).text, 'Renens - Lausanne ');
    expect(
      (((result.children![1] as TextSpan).children![0] as TextSpan).children![0] as TextSpan).text,
      'via saut-de-mouton',
    );
    expect(
      (((result.children![1] as TextSpan).children![0] as TextSpan).children![0] as TextSpan).style,
      DASTextStyles.smallRoman.italic.boldStyle,
    );
  });
}
