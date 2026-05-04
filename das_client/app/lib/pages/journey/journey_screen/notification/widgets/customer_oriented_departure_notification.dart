import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/view_model/customer_oriented_departure_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/departure_process_dialog.dart';
import 'package:app/theme/das_colors.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:customer_oriented_departure/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class CustomerOrientedDepartureNotification extends StatelessWidget {
  const CustomerOrientedDepartureNotification({super.key, this.displayDepartureProcessButton = true});

  final bool displayDepartureProcessButton;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<CustomerOrientedDepartureViewModel>();

    return StreamBuilder<CustomerOrientedDepartureStatus>(
      stream: viewModel.status,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        return switch (snapshot.data!) {
          .wait => _WaitNotification(displayDepartureProcessButton: displayDepartureProcessButton),
          .ready => _ReadyNotification(
            displayDepartureProcessButton: displayDepartureProcessButton,
          ),
          .call => _CallNotification(displayDepartureProcessButton: displayDepartureProcessButton),
          .departure => SizedBox.shrink(),
        };
      },
    );
  }
}

class _WaitNotification extends StatelessWidget {
  const _WaitNotification({required this.displayDepartureProcessButton});

  final bool displayDepartureProcessButton;

  @override
  Widget build(BuildContext context) {
    return _BaseNotification(
      title: context.l10n.w_customer_oriented_departure_notification_wait,
      leading: SvgPicture.asset(
        AppAssets.iconCustomerOrientedDepartureWait,
        colorFilter: ColorFilter.mode(SBBColors.black, BlendMode.srcIn),
      ),
      style: _promotionBoxStyle(
        context,
        borderColor: SBBColors.white,
        gradientColors: List.filled(4, DASColors.customerOrientedDepartureBlue),
      ),
      displayDepartureProcessButton: displayDepartureProcessButton,
    );
  }
}

class _CallNotification extends StatelessWidget {
  const _CallNotification({required this.displayDepartureProcessButton});

  final bool displayDepartureProcessButton;

  @override
  Widget build(BuildContext context) {
    return _BaseNotification(
      title: context.l10n.w_customer_oriented_departure_notification_call,
      leading: SvgPicture.asset(
        AppAssets.iconExclamationPointLine,
        colorFilter: ColorFilter.mode(SBBColors.black, BlendMode.srcIn),
      ),
      style: _promotionBoxStyle(
        context,
        borderColor: SBBColors.white,
        gradientColors: List.filled(4, DASColors.customerOrientedDepartureBlue),
      ),
      displayDepartureProcessButton: displayDepartureProcessButton,
    );
  }
}

class _ReadyNotification extends StatelessWidget {
  const _ReadyNotification({required this.displayDepartureProcessButton});

  final bool displayDepartureProcessButton;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeUtil.isDarkMode(context);
    return _BaseNotification(
      title: context.l10n.w_customer_oriented_departure_notification_departure,
      leading: Icon(SBBIcons.circle_tick_medium, color: SBBColors.black, size: 36.0),
      style: _promotionBoxStyle(
        context,
        borderColor: isDark ? SBBColors.royalDark : SBBColors.royal,
        gradientColors: List.filled(4, SBBColors.cloud),
      ),
      displayDepartureProcessButton: displayDepartureProcessButton,
    );
  }
}

class _BaseNotification extends StatelessWidget {
  const _BaseNotification({
    required this.leading,
    required this.title,
    required this.style,
    required this.displayDepartureProcessButton,
  });

  final Widget leading;
  final String title;
  final bool displayDepartureProcessButton;
  final PromotionBoxStyle style;

  @override
  Widget build(BuildContext context) {
    final resolvedTextStyle = ThemeUtil.isDarkMode(context)
        ? sbbTextStyle.boldStyle.large.copyWith(color: SBBColors.black)
        : sbbTextStyle.romanStyle.large.copyWith(color: SBBColors.black);

    return SBBPromotionBox.custom(
      leading: leading,
      content: Text(title, style: resolvedTextStyle),
      badgeText: context.l10n.w_customer_oriented_departure_notification_title,
      trailing: displayDepartureProcessButton ? _departureProcessButton(context) : null,
      style: style,
    );
  }

  Widget _departureProcessButton(BuildContext context) {
    final viewModel = context.read<UxTestingViewModel>();
    return FutureBuilder(
      future: viewModel.isDepartureProcessFeatureEnabled,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == false) return SizedBox.shrink();

        return SBBTertiaryButtonSmall(
          label: context.l10n.w_customer_oriented_departure_notification_departure_process,
          onPressed: () => showDepartureProcessDialog(context),
        );
      },
    );
  }
}

PromotionBoxStyle _promotionBoxStyle(BuildContext context, {List<Color>? gradientColors, Color? borderColor}) {
  final isDark = ThemeUtil.isDarkMode(context);
  final resolvedBadgeShadowColor = SBBColors.royal.withValues(alpha: isDark ? 0.6 : 0.2);
  return PromotionBoxStyle.$default(baseStyle: SBBBaseStyle.of(context)).copyWith(
    badgeColor: isDark ? SBBColors.royalDark : SBBColors.royal,
    badgeBorderColor: SBBColors.white,
    badgeShadowColor: resolvedBadgeShadowColor,
    gradientColors: gradientColors,
    borderColor: borderColor,
  );
}
