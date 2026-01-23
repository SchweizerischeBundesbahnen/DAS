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
            blurRadius: 8,
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
                SizedBox(height: 8.0),
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
      padding: EdgeInsets.fromLTRB(56, 24, 32, 32),
      color: SBBColors.white,
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

        final children = switch (model) {
          LoggedOut() || Loading() || LoggedIn() => [
            Text(context.l10n.p_login_bottom_sheet_title, style: sbbTextStyle.boldStyle.xLarge),
            Text(context.l10n.p_login_bottom_sheet_subtitle),
          ],
          Error(errorMessage: final errorMessage) => [
            Row(
              mainAxisSize: .min,
              children: [
                Icon(SBBIcons.circle_cross_small, color: SBBColors.red),
                SizedBox(width: SBBSpacing.xSmall),
                Text(context.l10n.p_login_bottom_sheet_title_failed, style: sbbTextStyle.boldStyle.xLarge),
              ],
            ),
            Text('${context.l10n.p_login_bottom_sheet_subtitle_failed}: $errorMessage'),
          ],
        };

        return Column(mainAxisSize: .min, spacing: 8.0, children: children);
      },
    );
  }
}
