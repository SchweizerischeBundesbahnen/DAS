import 'dart:math' show min;

import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/flavor.dart';
import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/device_screen.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

final _log = Logger('LoginDraggableBottomSheet');

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

  bool isTmsChecked = false;
  bool isLoading = false;

  String? errorText;

  @override
  void initState() {
    DI.resetToUnauthenticatedScope(useTms: isTmsChecked);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, asyncSnapshot) {
        final packageInfo = asyncSnapshot.data;

        if (packageInfo == null) return SizedBox.shrink();

        return DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: minHeight,
          maxChildSize: 0.5,
          minChildSize: minHeight,
          builder: (context, controller) => Container(
            clipBehavior: Clip.hardEdge,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sbbDefaultSpacing),
                  topRight: Radius.circular(sbbDefaultSpacing),
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
            child: CustomScrollView(
              controller: controller,
              slivers: [
                PinnedHeaderSliver(child: _header(context)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    vertical: sbbDefaultSpacing * 2,
                    horizontal: sbbDefaultSpacing * .5,
                  ),
                  sliver: SliverToBoxAdapter(child: _body(context, packageInfo)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Column _body(BuildContext context, PackageInfo packageInfo) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        SBBGroup(
          child: SBBSwitchListItem(
            title: context.l10n.p_login_connect_to_tms,
            value: isTmsChecked,
            onChanged: (value) {
              setState(() {
                isTmsChecked = value;
                DI.resetToUnauthenticatedScope(useTms: isTmsChecked);
              });
            },
            isLastElement: true,
          ),
        ),
        SizedBox(height: sbbDefaultSpacing * 2),
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
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(56, 24, 32, 32),
      color: SBBColors.white,
      child: Row(
        children: [
          Expanded(child: _message(context)),
          _loginButton(context),
        ],
      ),
    );
  }

  Widget _message(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 8.0,
      children: [
        if (errorText == null) ...[
          Text(context.l10n.p_login_bottom_sheet_title, style: sbbTextStyle.boldStyle.xLarge),
          Text(context.l10n.p_login_bottom_sheet_subtitle),
        ],
        if (errorText != null) ...[
          Row(
            mainAxisSize: .min,
            children: [
              Icon(SBBIcons.circle_cross_small, color: SBBColors.red),
              SizedBox(width: sbbDefaultSpacing * .5),
              Text(context.l10n.p_login_bottom_sheet_title_failed, style: sbbTextStyle.boldStyle.xLarge),
            ],
          ),
          Text('${context.l10n.p_login_bottom_sheet_subtitle_failed}: $errorText'),
        ],
      ],
    );
  }

  Widget _loginButton(BuildContext context) {
    if (errorText != null) {
      return SBBIconButtonLarge(icon: SBBIcons.arrow_circle_reset_medium, onPressed: () => _onLoginPressed(context));
    }

    // TODO: change to SBBSecondaryButton with custom label once v5.0.0 is released
    // TODO: https://github.com/SchweizerischeBundesbahnen/design_system_flutter/pull/425
    return OutlinedButton(
      onPressed: isLoading ? null : () => _onLoginPressed(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(context.l10n.p_login_login_button_text),
      ),
    );
  }

  void _onLoginPressed(BuildContext context) async {
    final authenticator = DI.get<Authenticator>();

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      await authenticator.login();
      await DI.get<ScopeHandler>().push<AuthenticatedScope>();
      await DI.get<ScopeHandler>().push<JourneyScope>();
      if (context.mounted) {
        context.router.replace(const JourneySelectionRoute());
      }
    } catch (e) {
      _log.severe('Login failed', e);
      setState(() {
        isLoading = false;
        errorText = e.toString();
      });
    }
  }
}
