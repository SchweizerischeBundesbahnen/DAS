import 'package:app/pages/journey/journey_screen/view_model/line_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedCellBody extends StatelessWidget {
  static const Key nonEmptyKey = Key('AdvisedSpeedCellBodyNonEmptyKey');
  static const Key advisedSpeedDistKey = Key('AdvisedSpeedCellBodyNonEmptyDISTKey');

  const AdvisedSpeedCellBody({
    required this.metadata,
    required this.order,
    required this.showSpeedBehavior,
    super.key,
  });

  final Metadata metadata;
  final int order;
  final ShowSpeedBehavior showSpeedBehavior;

  @override
  Widget build(BuildContext context) {
    return _backgroundStack(
      context,
      _content(context),
    );
  }

  Widget _content(BuildContext context) {
    if (showSpeedBehavior == .never) {
      return DASTableCell.emptyBuilder;
    }

    final inEtcsLevel2Segment = metadata.nonStandardTrackEquipmentSegments.isInEtcsLevel2Segment(order);
    final advisedSpeed = metadata.advisedSpeedSegments.appliesToOrder(order).firstOrNull;
    if (inEtcsLevel2Segment || advisedSpeed == null) return DASTableCell.emptyBuilder;

    var speed = advisedSpeed.speed;
    if (advisedSpeed is VelocityMaxAdvisedSpeedSegment) {
      final lineSpeedViewModel = context.read<LineSpeedViewModel>();
      speed = lineSpeedViewModel.getResolvedSpeedForOrder(order).speed?.speed as SingleSpeed?;
    }

    final resolvedTextColor = ThemeUtil.getColor(context, SBBColors.white, SBBColors.black);
    final resolvedSpeedDisplay = advisedSpeed.isDIST ? '' : speed?.value ?? '';
    return Text(
      resolvedSpeedDisplay,
      key: advisedSpeed.isDIST ? advisedSpeedDistKey : nonEmptyKey,
      style: sbbTextStyle.boldStyle.large.copyWith(color: resolvedTextColor),
    );
  }

  Widget _backgroundStack(BuildContext context, Widget child) {
    final horizontalBorderWidth =
        DASTableTheme.of(context)?.data.tableBorder?.horizontalInside.width ?? SBBSpacing.medium;
    final resolvedBackgroundColor = ThemeUtil.getColor(context, SBBColors.iron, SBBColors.platinum);

    return Stack(
      clipBehavior: .none,
      children: [
        Positioned(
          top: -horizontalBorderWidth * 2,
          bottom: -horizontalBorderWidth * 2,
          left: 0,
          right: 0,
          child: Container(color: resolvedBackgroundColor),
        ),
        Center(child: child),
      ],
    );
  }
}
