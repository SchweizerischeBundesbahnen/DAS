import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

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
        color: SBBColors.cloud,
        borderRadius: BorderRadius.all(Radius.circular(sbbDefaultSpacing)),
      ),
      child: Column(
        children: [
          SBBGroup(
            useShadow: false,
            child: child,
          ),
          if (information != null) _information(),
        ],
      ),
    );
  }

  Widget _information() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing, vertical: sbbDefaultSpacing * 0.5),
      child: Row(
        spacing: sbbDefaultSpacing * 0.5,
        children: [
          Icon(SBBIcons.circle_information_small, size: 20.0),
          Text(information!, style: DASTextStyles.smallLight),
        ],
      ),
    );
  }
}
