import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/adaptive_steering/adaptive_steering_state.dart';
import 'package:app/pages/journey/train_journey/adaptive_steering/adaptive_steering_view_model.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdaptiveSteeringNotification extends StatelessWidget {
  static const Key adaptiveSteeringNotificationKey = Key('adlNotification');
  static const Key adaptiveSteeringNotificationIconKey = Key('adlNotificationIcon');

  const AdaptiveSteeringNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AdaptiveSteeringViewModel>();

    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([viewModel.activeAdl, viewModel.adaptiveSteeringState]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final adlState = snapshot.data![1] as AdaptiveSteeringState;
        final adl = snapshot.data![0] as AdvisedSpeedSegment?;
        return switch (adlState) {
          AdaptiveSteeringState.active => adl != null ? _activeAdlMessage(context, adl) : SizedBox.shrink(),
          AdaptiveSteeringState.inactive => SizedBox.shrink(),
          AdaptiveSteeringState.end => _adlNotificationContainer(context, context.l10n.w_adl_end),
          AdaptiveSteeringState.cancel => _adlNotificationContainer(context, context.l10n.w_adl_cancel),
        };
      },
    );
  }

  Widget _activeAdlMessage(BuildContext context, AdvisedSpeedSegment adl) {
    return _adlNotificationContainer(context, _adlMessageText(context, adl), icon: _adlIcon(adl));
  }

  String _adlMessageText(BuildContext context, AdvisedSpeedSegment adl) {
    return switch (adl) {
      FollowTrainAdvisedSpeedSegment() => context.l10n.w_adl_vopt(adl.speed.value, _adlEndPoint(adl) ?? ''),
      TrainFollowingAdvisedSpeedSegment() => context.l10n.w_adl_vopt(adl.speed.value, _adlEndPoint(adl) ?? ''),
      FixedTimeAdvisedSpeedSegment() => context.l10n.w_adl_vopt(adl.speed.value, _adlEndPoint(adl) ?? ''),
      VelocityMaxAdvisedSpeedSegment() => context.l10n.w_adl_vmax(_adlEndPoint(adl) ?? ''),
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

  String? _adlIcon(AdvisedSpeedSegment adl) {
    return switch (adl) {
      FollowTrainAdvisedSpeedSegment() => AppAssets.iconAdvisedSpeedFollowTrain,
      TrainFollowingAdvisedSpeedSegment() => AppAssets.iconAdvisedSpeedTrainFollowing,
      FixedTimeAdvisedSpeedSegment() => AppAssets.iconAdvisedSpeedFixedTime,
      _ => null,
    };
  }

  Widget _adlNotificationContainer(BuildContext context, String message, {String? icon}) {
    return Container(
      key: adaptiveSteeringNotificationKey,
      margin: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5).copyWith(bottom: sbbDefaultSpacing * 0.5),
      decoration: BoxDecoration(
        color: SBBColors.iron,
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14.0).copyWith(left: sbbDefaultSpacing, right: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              icon,
              key: adaptiveSteeringNotificationIconKey,
              colorFilter: ColorFilter.mode(SBBColors.white, BlendMode.srcIn),
            ),
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
