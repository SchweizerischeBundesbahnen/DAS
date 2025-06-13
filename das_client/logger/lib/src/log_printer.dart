import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';

import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

class LogPrinter {
  const LogPrinter({this.appName = '', this.forcePrint = false, this.isDebugMode = false});

  final String appName;
  final bool forcePrint;
  final bool isDebugMode;

  void call(LogRecord record) {
    if (!forcePrint && !isDebugMode) {
      return;
    }
    ansiColorDisabled = false;
    final prefix = appName.isNotEmpty && !Platform.isIOS ? '[$appName] ' : '';
    final metadata = record.metadata;
    _printMessage(prefix, metadata, record);
    final padding = ''.padLeft(prefix.length + metadata.length);
    _printError(padding, record);
    _printStackTrace(padding, record);
  }

  void _printMessage(String prefix, String metadata, LogRecord record) {
    final padding = ''.padLeft(metadata.length);
    final pen = record.pen;
    const splitter = LineSplitter();
    final lines = splitter.convert(record.message);
    for (var i = 0; i < lines.length; i++) {
      var text = lines[i];
      if (i == 0) {
        text = '$metadata$text';
      } else {
        text = '$padding$text';
      }
      // Split the text to parts that have max 800 chars.
      final maxLineLength = 800 - prefix.length;
      final regExp = RegExp('.{1,$maxLineLength}');
      final matches = regExp.allMatches(text).toList();
      for (var j = 0; j < matches.length; j++) {
        text = matches[j].group(0) ?? '';
        if (text.isNotEmpty) {
          text = pen.write(text);
          if (j == 0) {
            _print('$prefix$text', record);
          } else {
            _print(text, record);
          }
        }
      }
    }
  }

  void _printError(String padding, LogRecord record) {
    final error = record.error;
    if (error != null) {
      final text = error.toString();
      _print('$padding↳ $text', record);
    }
  }

  void _printStackTrace(String padding, LogRecord record) {
    final stackTrace = record.stackTrace;
    if (stackTrace != null) {
      final text = stackTrace.toString().split('\n').join('\n$padding ');
      _print('$padding↳ $text', record);
    }
  }

  void _print(String text, LogRecord record) {
    if (Platform.isIOS) {
      developer.log(
        text,
        time: record.time,
        sequenceNumber: record.sequenceNumber,
        level: record.level.value,
        name: appName,
        zone: record.zone,
      );
    } else {
      // ignore: avoid_print
      print(text);
    }
  }
}

/// See: https://flatuicolors.com/palette/defo
class _Color {
  static const alizarin = Color(0xffe74c3c);
  static const pumpkin = Color(0xffd35400);
  static const orange = Color(0xfff39c12);
  static const emerald = Color(0xff2ecc71);
  static const peterRiver = Color(0xff3498db);
  static const silver = Color(0xffbdc3c7);
  static const concrete = Color(0xff95a5a6);
  static const asbestos = Color(0xff7f8c8d);
}

extension _LogRecordX on LogRecord {
  String get metadata {
    return [time.format(), level.name.padRight(7), '$loggerName:', ''].join(' ');
  }

  AnsiPen get pen {
    final color = switch (level) {
      Level.SHOUT => _Color.alizarin,
      Level.SEVERE => _Color.pumpkin,
      Level.WARNING => _Color.orange,
      Level.INFO => _Color.emerald,
      Level.CONFIG => _Color.peterRiver,
      Level.FINE => _Color.silver,
      Level.FINER => _Color.concrete,
      _ => _Color.asbestos,
    };
    final pen = AnsiPen();
    pen.rgb(r: color.r, g: color.g, b: color.b);
    return pen;
  }
}

extension _DateTimeX on DateTime {
  String format() {
    final year = this.year.toString().padLeft(4, '0');
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    final second = this.second.toString().padLeft(2, '0');
    return '$year.$month.$day $hour:$minute:$second';
  }
}
