import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/util/animation.dart';
import 'package:app/widgets/general_short_term_change_indicator.dart';
import 'package:app/widgets/u_turn_indicator.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ServicePointInformationCellTitle extends StatelessWidget {
  const ServicePointInformationCellTitle({
    required this.name,
    required this.foregroundColor,
    required this.isStation,
    required this.trackGroup,
    required this.shortTermChange,
    super.key,
  });

  final String name;
  final Color? foregroundColor;
  final bool isStation;
  final String? trackGroup;
  final ShortTermChange? shortTermChange;

  @override
  Widget build(BuildContext context) {
    DetailModalViewModel? detailModalVM;
    try {
      detailModalVM = context.read<DetailModalViewModel>();
    } on ProviderNotFoundException {
      // detailModalVM is not provided in [ReducedJourneyTable] and is always false
    }

    return StreamBuilder<bool>(
      stream: detailModalVM?.isModalOpen ?? Stream.value(false),
      initialData: detailModalVM?.isModalOpenValue ?? false,
      builder: (context, asyncSnapshot) {
        final isModalOpen = asyncSnapshot.requireData;
        Widget textTitle = Text(
          name,
          textAlign: TextAlign.start,
          overflow: .ellipsis,
        );
        if (shortTermChange != null) {
          textTitle = wrapWithIndicator(textTitle);
        }

        return DefaultTextStyle.merge(
          style: isStation
              ? sbbTextStyle.boldStyle.xLarge.copyWith(color: foregroundColor)
              : sbbTextStyle.lightStyle.xLarge.italic.copyWith(color: foregroundColor),
          child: AnimatedSwitcher(
            duration: DASAnimation.longDuration,
            child: Row(
              mainAxisAlignment: isModalOpen ? .spaceBetween : .start,
              children: [
                Flexible(child: textTitle),
                if (trackGroup != null) ...[
                  if (!isModalOpen) SizedBox(width: SBBSpacing.medium),
                  Text(trackGroup!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget wrapWithIndicator(Widget textTitle) {
    return shortTermChange is EndDestinationChange
        ? UTurnIndicator(offset: Offset(4, -28), child: textTitle)
        : GeneralShortTermChangeIndicator(offset: Offset(-8, -22), child: textTitle);
  }
}
