import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Adds AppBar color behind [child] that gives the impression of an extended AppBar.
class ExtendedAppBarWrapper extends StatelessWidget {
  const ExtendedAppBarWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _background(context),
        child,
      ],
    );
  }

  Widget _background(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    return Positioned(
      right: 0,
      left: 0,
      top: 0,
      child: Container(
        color: primary,
        height: sbbDefaultSpacing * 2,
      ),
    );
  }
}
