import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Header extends StatelessWidget {
  const Header({required this.child, super.key, this.information});

  final Widget child;

  /// information text is shown below header card if given.
  final String? information;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _background(context),
        _container(context),
      ],
    );
  }

  Widget _background(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    return Container(
      color: primary,
      height: sbbDefaultSpacing * 2,
    );
  }

  Widget _container(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(
        sbbDefaultSpacing * 0.5,
        0,
        sbbDefaultSpacing * 0.5,
        sbbDefaultSpacing,
      ),
      decoration: BoxDecoration(
        color: ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.granite),
        borderRadius: BorderRadius.all(Radius.circular(sbbDefaultSpacing)),
      ),
      child: Column(
        children: [
          SBBGroup(child: child),
          if (information != null) _information(context),
        ],
      ),
    );
  }

  Widget _information(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing, vertical: sbbDefaultSpacing * 0.5),
      child: Row(
        spacing: sbbDefaultSpacing * 0.5,
        children: [
          Icon(
            SBBIcons.circle_information_small,
            size: 20.0,
            color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.white),
          ),
          Text(
            information!,
            style: DASTextStyles.smallLight.copyWith(
              color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
