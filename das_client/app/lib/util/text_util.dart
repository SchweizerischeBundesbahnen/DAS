import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TextUtil {
  static TextSpan parseHtmlText(String text, TextStyle baseTextStyle) {
    return _parseHtmlTextTags(balanceHtmlTags(replaceHtmlLineBreaks(text)), baseTextStyle);
  }

  static String replaceHtmlLineBreaks(String text) {
    return text.replaceAll(RegExp(r'<br\s*/?>'), '\n');
  }

  static bool hasTextOverflow(String text,
      double maxWidth,
      TextStyle style, {
        TextScaler textScaler = TextScaler.noScaling,
        int maxLines = 1,
      }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )
      ..layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.didExceedMaxLines;
  }

  static String balanceHtmlTags(String text) {
    final openTags = <String>[];
    final regex = RegExp(r'<(/?)(\w+)>', caseSensitive: false);

    // Find all opening and closing tags
    for (final match in regex.allMatches(text)) {
      final tagName = match.group(2)!.toLowerCase();
      if (match.group(1) == '/') {
        if (openTags.isNotEmpty && openTags.last == tagName) {
          openTags.removeLast();
        }
      } else {
        openTags.add(tagName);
      }
    }

    // Close any remaining open tags
    while (openTags.isNotEmpty) {
      text += '</${openTags.removeLast()}>';
    }

    return text;
  }

  /// replaces all line breaks by given [delimiter]
  static String replaceLineBreaks(String input, {String delimiter = '; '}) {
    final pattern = RegExp(r'(\r\n|\r|\n|<br\s*/?>)', multiLine: true);
    return input.replaceAll(pattern, delimiter);
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
