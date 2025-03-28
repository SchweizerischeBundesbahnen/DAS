import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TextUtil {
  static TextSpan parseHtmlText(String text, TextStyle baseTextStyle) {
    return _parseHtmlTextTags(replaceHtmlLineBreaks(text), baseTextStyle);
  }

  static String replaceHtmlLineBreaks(String text) {
    return text.replaceAll(RegExp(r'<br\s*/?>'), '\n');
  }

  static TextSpan _parseHtmlTextTags(String text, TextStyle baseTextStyle) {
    final regex = RegExp(r'<(b|i)>(.*?)<\/\1>', caseSensitive: false);

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    regex.allMatches(text).forEach((match) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: baseTextStyle));
      }

      final tag = match.group(1)!;
      final content = match.group(2)!;

      if (tag.toLowerCase() == 'b') {
        spans.add(_parseHtmlTextTags(content, baseTextStyle.boldStyle));
      } else if (tag.toLowerCase() == 'i') {
        spans.add(_parseHtmlTextTags(content, baseTextStyle.italic));
      }

      lastMatchEnd = match.end;
    });

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseTextStyle));
    }

    return TextSpan(children: spans);
  }
}
