import 'dart:math' show min;

import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/pages/login/login_model.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:app/pages/login/widgets/login_button.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/device_screen.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class LoginDraggableBottomSheet extends StatefulWidget {
  @override
  State<LoginDraggableBottomSheet> createState() => _LoginDraggableBottomSheetState();

  static const _minHeight = 116.0;

  const LoginDraggableBottomSheet({super.key});
}

class _LoginDraggableBottomSheetState extends State<LoginDraggableBottomSheet> {
  final _controller = DraggableScrollableController();
  final minHeight = min(LoginDraggableBottomSheet._minHeight / DeviceScreen.size.height, 0.5);

  final flavor = DI.get<Flavor>();
  final _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: minHeight,
      maxChildSize: 0.5,
      minChildSize: minHeight,
      builder: (context, controller) => _roundedShadowedSheet(
        child: CustomScrollView(
          controller: controller,
          slivers: [
            PinnedHeaderSliver(child: _header(context)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                vertical: SBBSpacing.xLarge,
                horizontal: SBBSpacing.xSmall,
              ),
              sliver: SliverToBoxAdapter(child: _body(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundedShadowedSheet({required Widget child}) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SBBSpacing.medium),
            topRight: Radius.circular(SBBSpacing.medium),
          ),
        ),
        shadows: [
          BoxShadow(
            color: SBBColors.black.withValues(alpha: 0.2),
            blurRadius: SBBSpacing.xSmall,
          ),
        ],
        color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      ),
      child: child,
    );
  }

  Widget _body(BuildContext context) {
    final vm = context.read<LoginViewModel>();

    return Column(
      crossAxisAlignment: .start,
      children: [
        StreamBuilder(
          stream: vm.model,
          initialData: vm.modelValue,
          builder: (context, asyncSnapshot) {
            final model = asyncSnapshot.requireData;
            return SBBContentBox(
              child: SBBSwitchListItem(
                title: context.l10n.p_login_connect_to_tms,
                value: model.connectToTmsVad,
                onChanged: vm.setConnectToTmsVad,
                isLastElement: true,
              ),
            );
          },
        ),
        SizedBox(height: SBBSpacing.xLarge),
        RichText(
          text: TextSpan(
            text: 'App Flavor: ',
            style: DASTextStyles.smallLight.copyWith(color: SBBColors.granite),
            children: [
              TextSpan(
                text: flavor.displayName,
                style: DASTextStyles.smallBold.copyWith(color: SBBColors.granite),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: _packageInfo,
          builder: (context, asyncSnapshot) {
            final packageInfo = asyncSnapshot.data;

            if (packageInfo == null) return SizedBox.shrink();
            return Column(
              children: [
                SizedBox(height: SBBSpacing.xSmall),
                RichText(
                  text: TextSpan(
                    text: 'App Version: ',
                    style: DASTextStyles.smallLight.copyWith(color: SBBColors.granite),
                    children: [
                      TextSpan(
                        text: '${packageInfo.version}+${packageInfo.buildNumber}',
                        style: DASTextStyles.smallBold.copyWith(color: SBBColors.granite),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(56, SBBSpacing.large, SBBSpacing.xLarge, SBBSpacing.xLarge),
      color: SBBColors.white,
      constraints: BoxConstraints(minHeight: LoginDraggableBottomSheet._minHeight),
      child: Row(
        children: [
          Expanded(child: _titleAndSubtitle(context)),
          LoginButton(),
        ],
      ),
    );
  }

  Widget _titleAndSubtitle(BuildContext context) {
    final vm = context.read<LoginViewModel>();
    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, asyncSnapshot) {
        final model = asyncSnapshot.requireData;

        return switch (model) {
          LoggedOut() || Loading() || LoggedIn() => Column(
            mainAxisSize: .min,
            spacing: SBBSpacing.xSmall,
            children: [
              Text(context.l10n.p_login_bottom_sheet_title, style: sbbTextStyle.boldStyle.xLarge),
              Text(context.l10n.p_login_bottom_sheet_subtitle),
            ],
          ),
          Error() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                SBBIcons.circle_cross_small,
                color: ThemeUtil.getColor(context, SBBColors.error, SBBColors.errorDark),
              ),
              SizedBox(width: SBBSpacing.xSmall),
              Text(context.l10n.p_login_bottom_sheet_title_failed, style: sbbTextStyle.boldStyle.xLarge),
            ],
          ),
        };
      },
    );
  }
}
