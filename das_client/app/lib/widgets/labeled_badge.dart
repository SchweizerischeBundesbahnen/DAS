import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Adds badge with a [label] to the [child]. Position can be defined with the [offset].
class LabeledBadge extends StatelessWidget {
  static const Key labeledBadgeKey = Key('labeledBadge');

  const LabeledBadge({
    required this.child,
    this.label,
    this.offset = const Offset(0, 0),
    this.size = 8.0,
    super.key,
  });

  final Offset offset;
  final double size;
  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (label == null) return child;

    return Stack(
      clipBehavior: .none,
      children: [
        child,
        Positioned(
          top: offset.dx,
          right: offset.dy,
          child: _badge(context),
        ),
      ],
    );
  }

  Widget _badge(BuildContext context) {
    return Container(
      key: labeledBadgeKey,
      constraints: const BoxConstraints(minWidth: 18.0),
      height: 18.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Center(
        child: Text(
          label ?? '',
          style: DASTextStyles.extraSmallBold.copyWith(
            color: SBBColors.white,
            fontWeight: .w700,
          ),
        ),
      ),
    );
  }
}
