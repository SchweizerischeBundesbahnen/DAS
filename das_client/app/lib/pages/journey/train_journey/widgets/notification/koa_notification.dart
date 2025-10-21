import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/pages/journey/train_journey/ux_testing_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/departure_process_modal_sheet.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class KoaNotification extends StatelessWidget {
  const KoaNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UxTestingViewModel>();

    return StreamBuilder<KoaState>(
      stream: viewModel.koaState,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == KoaState.waitHide) return SizedBox.shrink();
        return Container(
          margin: EdgeInsets.all(TrainJourneyOverview.horizontalPadding).copyWith(top: 0),
          child: snapshot.data == KoaState.wait ? _WaitNotification() : _WaitCancelledNotification(),
        );
      },
    );
  }
}

class _WaitNotification extends StatelessWidget {
  const _WaitNotification();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.brightnessOf(context) == Brightness.light;
    final resolvedTextStyle = isLight
        ? DASTextStyles.mediumRoman.copyWith(color: SBBColors.black)
        : DASTextStyles.mediumBold.copyWith(color: SBBColors.white);

    return SBBPromotionBox.custom(
      leading: SvgPicture.asset(
        AppAssets.iconKoaWait,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      content: Text(
        context.l10n.w_koa_notification_wait,
        style: resolvedTextStyle,
      ),
      badgeText: context.l10n.w_koa_notification_title,
      trailing: _KoaTrailingButton(),
      style: _waitStyle(context),
    );
  }

  PromotionBoxStyle _waitStyle(BuildContext context) {
    final isLight = Theme.brightnessOf(context) == Brightness.light;
    final resolvedGradientColors = isLight
        ? [SBBColors.cloud, SBBColors.milk, SBBColors.milk, SBBColors.cloud]
        : [Color(0xFF0079C7), Color(0xFF143A85), Color(0xFF143A85), Color(0xFF0079C7)];
    final resolvedBadgeShadowColor = isLight
        ? SBBColors.royal.withValues(alpha: 0.2)
        : SBBColors.royal.withValues(alpha: 0.6);

    return PromotionBoxStyle.$default(baseStyle: SBBBaseStyle.of(context)).copyWith(
      badgeColor: SBBColors.royal,
      badgeBorderColor: SBBColors.white,
      badgeShadowColor: resolvedBadgeShadowColor,
      gradientColors: resolvedGradientColors,
    );
  }
}

class _WaitCancelledNotification extends StatelessWidget {
  const _WaitCancelledNotification();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.brightnessOf(context) == Brightness.light;
    final resolvedTextStyle = isLight
        ? DASTextStyles.mediumRoman.copyWith(color: SBBColors.black)
        : DASTextStyles.mediumBold.copyWith(color: SBBColors.black);

    return SBBPromotionBox.custom(
      leading: Icon(SBBIcons.circle_tick_medium, color: SBBColors.black, size: 36.0),
      content: Text(context.l10n.w_koa_notification_wait_canceled, style: resolvedTextStyle),
      badgeText: context.l10n.w_koa_notification_title,
      trailing: _KoaTrailingButton(),
      style: _waitCancelledStyle(context),
    );
  }

  PromotionBoxStyle _waitCancelledStyle(BuildContext context) {
    final isLight = Theme.brightnessOf(context) == Brightness.light;
    final resolvedGradientColors = isLight
        ? [SBBColors.cloud, SBBColors.milk, SBBColors.milk, SBBColors.cloud]
        : [SBBColors.aluminum, SBBColors.cement, SBBColors.cement, SBBColors.aluminum];
    final resolvedBadgeShadowColor = isLight
        ? SBBColors.royal.withValues(alpha: 0.2)
        : SBBColors.royal.withValues(alpha: 0.6);

    return PromotionBoxStyle.$default(baseStyle: SBBBaseStyle.of(context)).copyWith(
      borderColor: SBBColors.royal,
      badgeColor: SBBColors.royal,
      badgeBorderColor: SBBColors.white,
      badgeShadowColor: resolvedBadgeShadowColor,
      gradientColors: resolvedGradientColors,
    );
  }
}

class _KoaTrailingButton extends StatelessWidget {
  const _KoaTrailingButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UxTestingViewModel>();
    return FutureBuilder(
      future: viewModel.isDepartueProcessFeatureEnabled,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == false) return SizedBox.shrink();

        return SBBTertiaryButtonSmall(
          label: context.l10n.w_koa_notification_departure_process,
          onPressed: () => showDepartureProcessModalSheet(context),
        );
      },
    );
  }
}
