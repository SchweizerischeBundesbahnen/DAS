import 'package:flutter/material.dart';

extension SpacingExtension on List<Widget> {
  withSpacing({double? width, double? height}) {
    return expand((x) => [SizedBox(width: width, height: height), x])
        .skip(1)
        .toList();
  }
}