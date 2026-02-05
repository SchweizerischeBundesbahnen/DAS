import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/util/animation.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class ServicePointInformationCellTitle extends StatelessWidget {
  const ServicePointInformationCellTitle({
    super.key,
    required this.name,
    required this.foregroundColor,
    required this.isStation,
    required this.trackGroup,
    required this.shortTermChange,
  });

  final String name;
  final Color? foregroundColor;
  final bool isStation;
  final String? trackGroup;
  final ShortTermChange? shortTermChange;

  @override
  Widget build(BuildContext context) {
    final detailModalVM = context.read<DetailModalViewModel>();

    return StreamBuilder<bool>(
      stream: detailModalVM.isModalOpen,
      initialData: detailModalVM.isModalOpenValue,
      builder: (context, asyncSnapshot) {
        final isModalOpen = asyncSnapshot.requireData;
        return DefaultTextStyle.merge(
          style: isStation
              ? sbbTextStyle.boldStyle.xLarge.copyWith(color: foregroundColor)
              : sbbTextStyle.lightStyle.xLarge.italic.copyWith(color: foregroundColor),
          child: AnimatedSwitcher(
            duration: DASAnimation.longDuration,
            child: Row(
              mainAxisAlignment: isModalOpen ? .spaceBetween : .start,
              children: [
                Flexible(
                  child: DotIndicator(
                    show: shortTermChange != null,
                    child: Text(
                      name,
                      textAlign: TextAlign.start,
                      overflow: .ellipsis,
                    ),
                  ),
                ),
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
}
