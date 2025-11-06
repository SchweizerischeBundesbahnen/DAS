import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/advised_speed/advised_speed_model.dart';
import 'package:app/pages/journey/journey_table/advised_speed/advised_speed_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedNotification extends StatelessWidget {
  static const Key advisedSpeedNotificationKey = Key('advisedSpeedNotification');
  static const Key advisedSpeedNotificationIconKey = Key('advisedSpeedNotificationIcon');

  const AdvisedSpeedNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AdvisedSpeedViewModel>();

    return StreamBuilder<AdvisedSpeedModel>(
      stream: viewModel.model,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final model = snapshot.requireData;
        return switch (model) {
          Active() => _activeSegmentNotification(context, model.segment),
          End() => _notification(context, context.l10n.w_advised_speed_end),
          Cancel() => _notification(context, context.l10n.w_advised_speed_cancel),
          Inactive() => SizedBox.shrink(),
        };
      },
    );
  }

  Widget _activeSegmentNotification(BuildContext context, AdvisedSpeedSegment segment) => _notification(
    context,
    _activeSegmentTitle(context, segment),
    icon: segment.displayIcon(ThemeUtil.isDarkMode(context)),
  );

  String _activeSegmentTitle(BuildContext context, AdvisedSpeedSegment adl) => switch (adl) {
    FollowTrainAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(
      adl.speed.value,
      _advisedSegmentEndPoint(adl) ?? '',
    ),
    TrainFollowingAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(
      adl.speed.value,
      _advisedSegmentEndPoint(adl) ?? '',
    ),
    FixedTimeAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(
      adl.speed.value,
      _advisedSegmentEndPoint(adl) ?? '',
    ),
    VelocityMaxAdvisedSpeedSegment() => context.l10n.w_advised_speed_vmax(_advisedSegmentEndPoint(adl) ?? ''),
  };

  String? _advisedSegmentEndPoint(AdvisedSpeedSegment advisedSpeedSegment) {
    final end = advisedSpeedSegment.endData;
    return switch (end) {
      Signal() => end.visualIdentifier,
      ServicePoint() => end.name,
      _ => null,
    };
  }

  Widget _notification(BuildContext context, String message, {Widget? icon}) {
    final resolvedBackgroundColor = ThemeUtil.getColor(context, SBBColors.iron, SBBColors.platinum);
    final resolvedForegroundColor = ThemeUtil.getColor(context, SBBColors.white, SBBColors.black);

    return Container(
      key: advisedSpeedNotificationKey,
      margin: const EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(top: 0),
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      constraints: BoxConstraints(minHeight: 54.0),
      padding: EdgeInsets.only(left: 22.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: sbbDefaultSpacing * 0.5),
            ],
            Text(
              message,
              style: DASTextStyles.largeBold.copyWith(color: resolvedForegroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

extension _AdvisedSpeedSegmentX on AdvisedSpeedSegment {
  SvgPicture? displayIcon(bool isDarkMode) {
    final String? iconName = switch (this) {
      FollowTrainAdvisedSpeedSegment() => AppAssets.iconAdvisedSpeedFollowTrain,
      TrainFollowingAdvisedSpeedSegment() => AppAssets.iconAdvisedSpeedTrainFollowing,
      FixedTimeAdvisedSpeedSegment() => AppAssets.iconAdvisedSpeedFixedTime,
      _ => null,
    };
    return iconName != null
        ? SvgPicture.asset(
            iconName,
            key: AdvisedSpeedNotification.advisedSpeedNotificationIconKey,
            colorFilter: ColorFilter.mode(isDarkMode ? SBBColors.black : SBBColors.white, BlendMode.srcIn),
          )
        : null;
  }
}
