import 'package:app/util/text_util.dart';
import 'package:flutter/gestures.dart';
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

  test('textUtil_parseHtmlTextWithMarkdownLinks_italic', () {
    // GIVEN
    final input = 'Renens - Lausanne <i>via saut-de-mouton</i>';

    // WHEN
    final result = TextUtil.parseHtmlTextWithMarkdownLinks(input, sbbTextStyle.romanStyle.small);

    // THEN
    expect((result.children![0] as TextSpan).text, 'Renens - Lausanne ');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).text, 'via saut-de-mouton');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).style, sbbTextStyle.romanStyle.small.italic);
  });

  test('textUtil_parseHtmlTextWithMarkdownLinks_bold', () {
    // GIVEN
    final input = 'Renens - Lausanne <b>via saut-de-mouton</b>';

    // WHEN
    final result = TextUtil.parseHtmlTextWithMarkdownLinks(input, sbbTextStyle.romanStyle.small);

    // THEN
    expect((result.children![0] as TextSpan).text, 'Renens - Lausanne ');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).text, 'via saut-de-mouton');
    expect(((result.children![1] as TextSpan).children![0] as TextSpan).style, sbbTextStyle.romanStyle.small.boldStyle);
  });

  test('textUtil_parseHtmlTextWithMarkdownLinks_bold_italic', () {
    // GIVEN
    final input = 'Renens - Lausanne <i><b>via saut-de-mouton</b></i>';

    // WHEN
    final result = TextUtil.parseHtmlTextWithMarkdownLinks(input, sbbTextStyle.romanStyle.small);

    // THEN
    expect((result.children![0] as TextSpan).text, 'Renens - Lausanne ');
    expect(
      (((result.children![1] as TextSpan).children![0] as TextSpan).children![0] as TextSpan).text,
      'via saut-de-mouton',
    );
    expect(
      (((result.children![1] as TextSpan).children![0] as TextSpan).children![0] as TextSpan).style,
      sbbTextStyle.romanStyle.small.italic.boldStyle,
    );
  });

  test('textUtil_parseHtmlTextWithMarkdownLinks_parsesMarkdownLink', () {
    // GIVEN
    final input = 'Read [documentation](https://example.com) now';

    // WHEN
    final result = TextUtil.parseHtmlTextWithMarkdownLinks(input, sbbTextStyle.romanStyle.small, onLinkTap: (link) {});

    // THEN
    expect((result.children![0] as TextSpan).text, 'Read ');
    expect((result.children![1] as TextSpan).text, 'documentation');
    expect((result.children![2] as TextSpan).text, ' now');
    expect((result.children![1] as TextSpan).style?.decoration, TextDecoration.underline);
  });

  test('textUtil_parseHtmlTextWithMarkdownLinks_linkIsClickable', () {
    // GIVEN
    final input = '[example](https://example.com)';
    String? openedUrl;

    // WHEN
    final result = TextUtil.parseHtmlTextWithMarkdownLinks(
      input,
      sbbTextStyle.romanStyle.small,
      onLinkTap: (url) => openedUrl = url,
    );
    final linkSpan = result.children![0] as TextSpan;
    final recognizer = linkSpan.recognizer as TapGestureRecognizer;
    recognizer.onTap?.call();

    // THEN
    expect(openedUrl, 'https://example.com');
    recognizer.dispose();
  });
}
