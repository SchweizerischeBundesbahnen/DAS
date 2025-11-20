import 'package:flutter/animation.dart';

/// Defines animation properties to be used in DAS.
///
/// Uses Material 3 Motion docs as guide-line: https://m3.material.io/styles/motion/overview/how-it-works
class DASAnimation {
  const DASAnimation._();

  /// should be used for large expressive transitions.
  static const Duration longDuration = Duration(milliseconds: 500);

  /// should be used for transitions that traverse a medium area of the screen (small dialogs, menus etc.)
  static const Duration mediumDuration = Duration(milliseconds: 350);

  /// should be used for small utility-focused transitions and close transitions.
  static const Duration shortDuration = Duration(milliseconds: 200);

  /// Emphasized easing set is recommended for most transitions by M3
  static CurvedAnimation emphasizedEasingCurvedAnimation(Animation<double> parent) =>
      CurvedAnimation(parent: parent, curve: Curves.easeInOutCubicEmphasized);
}

extension AnimationControllerExtension on AnimationController {
  CurvedAnimation toEmphasizedEasingAnimation() => DASAnimation.emphasizedEasingCurvedAnimation(this);
}
