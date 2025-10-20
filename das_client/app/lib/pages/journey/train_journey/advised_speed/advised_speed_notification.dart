import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_model.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_view_model.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedNotification extends StatelessWidget {
  static const Key advisedSpeedNotificationKey = Key('adlNotification');
  static const Key advisedSpeedNotificationIconKey = Key('adlNotificationIcon');

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
          Active() => _activeAdlMessage(context, model.segment),
          End() => _adlNotificationContainer(context, context.l10n.w_advised_speed_end),
          Cancel() => _adlNotificationContainer(context, context.l10n.w_advised_speed_cancel),
          Inactive() => SizedBox.shrink(),
        };
      },
    );
  }

  Widget _activeAdlMessage(BuildContext context, AdvisedSpeedSegment segment) =>
      _adlNotificationContainer(context, _adlMessageText(context, segment), icon: segment.displayIcon());

  String _adlMessageText(BuildContext context, AdvisedSpeedSegment adl) {
    return switch (adl) {
      FollowTrainAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(adl.speed.value, _adlEndPoint(adl) ?? ''),
      TrainFollowingAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(
        adl.speed.value,
        _adlEndPoint(adl) ?? '',
      ),
      FixedTimeAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(adl.speed.value, _adlEndPoint(adl) ?? ''),
      VelocityMaxAdvisedSpeedSegment() => context.l10n.w_advised_speed_vmax(_adlEndPoint(adl) ?? ''),
    };
  }

  String? _adlEndPoint(AdvisedSpeedSegment adl) {
    final end = adl.endData;
    return switch (end) {
      Signal() => end.visualIdentifier,
      ServicePoint() => end.name,
      _ => null,
    };
  }

  Widget _adlNotificationContainer(BuildContext context, String message, {Widget? icon}) {
    return Container(
      key: advisedSpeedNotificationKey,
      margin: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5).copyWith(bottom: sbbDefaultSpacing * 0.5),
      decoration: BoxDecoration(
        color: SBBColors.iron,
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14.0).copyWith(left: sbbDefaultSpacing, right: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: sbbDefaultSpacing * 0.5),
          ],
          Text(
            message,
            style: DASTextStyles.mediumBold.copyWith(color: SBBColors.white),
          ),
        ],
      ),
    );
  }
}

extension _AdvisedSpeedSegmentX on AdvisedSpeedSegment {
  SvgPicture? displayIcon() {
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
            colorFilter: ColorFilter.mode(SBBColors.white, BlendMode.srcIn),
          )
        : null;
  }
}
