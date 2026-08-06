import 'package:flutter/material.dart';

/// Adds a floating [badge] over the [child]. Position can be defined with the [badgeOffset].
///
/// This widget owns only the floating/positioning logic. The widget shown
/// floating is passed in via [badge] (e.g. [DotIndicator], [UTurnIndicator]),
/// keeping the visual and the positioning as separate, composable concerns.
class DASBadgeOverlay extends StatelessWidget {
  const DASBadgeOverlay({
    required this.child,
    required this.badge,
    this.badgeVisible = true,
    this.badgeOffset = const Offset(0, 0),
    super.key,
  });

  final Widget child;
  final Widget badge;
  final bool badgeVisible;
  final Offset badgeOffset;

  @override
  Widget build(BuildContext context) {
    if (!badgeVisible) return child;

    return Stack(
      clipBehavior: .none,
      children: [
        child,
        Positioned(
          top: badgeOffset.dx,
          right: badgeOffset.dy,
          child: badge,
        ),
      ],
    );
  }
}
