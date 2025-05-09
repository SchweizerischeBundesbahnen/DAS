import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Shows a custom DAS Modal Sheet as [showSBBModalSheet] and [showCustomSBBModalSheet] always have a close button.
/// If close button is needed, use the ModalSheets from the SBB Design System.
///
/// TODO: Will be replaced in the future by SBB Design System: https://github.com/SchweizerischeBundesbahnen/design_system_flutter/issues/293
Future<T?> showDASModalSheet<T>({
  required BuildContext context,
  required Widget child,
  BoxConstraints? constraints,
  Color? backgroundColor,
  EdgeInsets? padding,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: SBBColors.transparent,
    constraints: constraints ?? const BoxConstraints(maxWidth: double.infinity),
    builder: (context) => DasModalBottomSheet(
      constraints: constraints,
      backgroundColor: backgroundColor,
      padding: padding,
      child: child,
    ),
  );
}

/// Custom DAS bottom sheet that follows the SBB guidelines without the close button.
class DasModalBottomSheet extends StatelessWidget {
  const DasModalBottomSheet({
    required this.child,
    super.key,
    this.constraints,
    this.backgroundColor,
    this.padding,
  });

  final Widget child;
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final style = SBBControlStyles.of(context);
    return Container(
      padding: padding ??
          EdgeInsets.fromLTRB(sbbDefaultSpacing, sbbDefaultSpacing, sbbDefaultSpacing, sbbDefaultSpacing * 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? style.modalBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(sbbDefaultSpacing),
          topRight: Radius.circular(sbbDefaultSpacing),
        ),
      ),
      child: child,
    );
  }
}
