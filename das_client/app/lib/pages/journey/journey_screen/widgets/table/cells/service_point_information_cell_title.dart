import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/util/animation.dart';
import 'package:app/widgets/das_badge_overlay.dart';
import 'package:app/widgets/modification_icon.dart';
import 'package:app/widgets/short_term_change_exclamation_icon.dart';
import 'package:app/widgets/u_turn_icon.dart';
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
    this.showModification = false,
  });

  final String name;
  final Color? foregroundColor;
  final bool isStation;
  final String? trackGroup;
  final ShortTermChange? shortTermChange;
  final bool showModification;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ModalViewModel>();

    return StreamBuilder<bool>(
      stream: vm.isModalOpen,
      initialData: vm.isModalOpenValue,
      builder: (context, asyncSnapshot) {
        final isModalOpen = asyncSnapshot.requireData;
        Widget textTitle = DASBadgeOverlay(
          badgeVisible: showModification,
          badgeOffset: Offset(0, -SBBSpacing.small),
          badge: const ModificationIcon(),
          child: Text(
            name,
            textAlign: TextAlign.start,
            overflow: .ellipsis,
          ),
        );
        if (shortTermChange != null) {
          textTitle = Row(
            mainAxisSize: .min,
            children: [
              Flexible(child: wrapWithIndicator(textTitle)),
              SizedBox(width: SBBSpacing.medium),
            ],
          );
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
        ? DASBadgeOverlay(
            badgeOffset: Offset(4, -28),
            badge: UTurnIcon(foregroundColor: foregroundColor),
            child: textTitle,
          )
        : DASBadgeOverlay(
            badgeOffset: Offset(-8, -22),
            badge: const ShortTermChangeExclamationIcon(),
            child: textTitle,
          );
  }
}
