import 'package:app/extension/single_speed_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/advised_speed_notification_hints.dart';
import 'package:app/pages/journey/journey_screen/view_model/advised_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/advised_speed_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:collection/collection.dart';
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
          Active() => _activeSegmentNotification(context, model),
          End() => _notificationBar(context, context.l10n.w_advised_speed_end),
          Cancel() => _notificationBar(context, context.l10n.w_advised_speed_cancel),
          Inactive() => SizedBox.shrink(),
        };
      },
    );
  }

  Widget _activeSegmentNotification(BuildContext context, Active model) {
    final notificationBar = _notificationBar(
      context,
      _title(context, model),
      suffix: _suffix(model.segment, context),
      icon: model.segment.displayIcon(ThemeUtil.isDarkMode(context)),
    );

    if (model.segment.additionalHints.isEmpty) return notificationBar;

    final lastHintIndex = model.segment.additionalHints.length - 1;

    return Stack(
      children: [
        notificationBar,
        ...model.segment.additionalHints.sortByDisplayOrder.mapIndexed(
          (idx, h) => Positioned(
            top: 0,
            right: (lastHintIndex - idx) * AdvisedSpeedNotificationHint.widthWithoutRoundedLeftEdge,
            child: AdvisedSpeedNotificationHint(hint: h, roundBottomRightCorner: lastHintIndex == idx),
          ),
        ),
      ],
    );
  }

  String? _suffix(AdvisedSpeedSegment segment, BuildContext context) {
    if (segment.isEndDataCalculated || segment.endData is! Signal) return null;
    final signalName = (segment.endData as Signal).visualIdentifier;
    if (signalName == null) return null;
    return context.l10n.w_advised_speed_drive_until(signalName);
  }

  String _title(BuildContext context, Active model) {
    if (model.segment.isDIST) return context.l10n.w_advised_speed_dist;
    return switch (model.segment) {
      FollowTrainAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(_speedDisplay(model)),
      TrainFollowingAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(_speedDisplay(model)),
      FixedTimeAdvisedSpeedSegment() => context.l10n.w_advised_speed_vopt(_speedDisplay(model)),
      VelocityMaxAdvisedSpeedSegment() => context.l10n.w_advised_speed_vmax,
    };
  }

  Widget _notificationBar(BuildContext context, String title, {String? suffix, Widget? icon}) {
    final resolvedBackgroundColor = ThemeUtil.getColor(context, SBBColors.iron, SBBColors.platinum);
    final resolvedForegroundColor = ThemeUtil.getColor(context, SBBColors.white, SBBColors.black);

    return Container(
      key: advisedSpeedNotificationKey,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(SBBSpacing.medium),
      ),
      constraints: BoxConstraints(minHeight: 52.0),
      padding: .only(left: SBBSpacing.large),
      child: Align(
        alignment: .centerLeft,
        child: Row(
          spacing: SBBSpacing.xSmall,
          children: [
            ?icon,
            Text(
              '$title${suffix ?? ''}',
              style: sbbTextStyle.boldStyle.large.copyWith(color: resolvedForegroundColor),
            ),
          ],
        ),
      ),
    );
  }

  String _speedDisplay(Active model) {
    if (model.segment.speed?.value == null) return '';
    if (model.lineSpeed == null) return model.segment.speed!.value;

    if (model.segment.speed?.isLargerThan(model.lineSpeed) ?? false) {
      return model.lineSpeed!.value;
    } else {
      return model.segment.speed!.value;
    }
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

extension _SortAdvisedSpeedSegmentHint on Set<AdvisedSpeedSegmentHint> {
  List<AdvisedSpeedSegmentHint> get sortByDisplayOrder {
    int getPriority(AdvisedSpeedSegmentHint hint) {
      return switch (hint) {
        .servicePointWithLocalSpeed => 0,
        .curvePointWithLocalSpeed => 1,
        .additionalSpeedRestriction => 2,
      };
    }

    return sorted((a, b) => getPriority(a).compareTo(getPriority(b))).toList(growable: false);
  }
}
