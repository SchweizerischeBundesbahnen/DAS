import 'package:app/util/animation.dart';
import 'package:app/widgets/general_short_term_change_indicator.dart';
import 'package:app/widgets/u_turn_indicator.dart';
import 'package:flutter/widgets.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ServicePointInformationCellTitle extends StatelessWidget {
  const ServicePointInformationCellTitle({
    required this.name,
    required this.foregroundColor,
    required this.isStation,
    required this.trackGroup,
    required this.shortTermChange,
    required this.isModalOpenValue,
    required this.isModalOpenStream,
    super.key,
  });

  final String name;
  final Color? foregroundColor;
  final bool isStation;
  final String? trackGroup;
  final ShortTermChange? shortTermChange;
  final bool isModalOpenValue;
  final Stream<bool> isModalOpenStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isModalOpenStream,
      initialData: isModalOpenValue,
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
