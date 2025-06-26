import 'package:flutter/material.dart';

extension WidgetListExtension on Iterable<Widget> {
  List<Widget> withDivider(final Widget divider) {
    return expand((x) => [divider, x]).skip(1).toList();
  }
}
