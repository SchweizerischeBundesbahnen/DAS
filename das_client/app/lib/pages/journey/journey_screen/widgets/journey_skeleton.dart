import 'package:app/pages/journey/journey_screen/journey_overview.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/loading_table.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/extended_header_container.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Skeleton loading placeholder for the journey overview screen.
class JourneySkeleton extends StatelessWidget {
  const JourneySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _headerSkeleton(context),
        const SizedBox(height: SBBSpacing.xSmall),
        Expanded(
          child: JourneyLoadingTable.withDefaults(context),
        ),
      ],
    );
  }

  Widget _headerSkeleton(BuildContext context) {
    final dividerColor = ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron);

    return ExtendedAppBarWrapper(
      child: Skeletonizer(
        enabled: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: JourneyOverview.horizontalPadding),
          child: Row(
            spacing: SBBSpacing.xSmall,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Box 1: Journey identifier & radio channel (width: 215, height: 144)
              SBBContentBox(
                padding: const EdgeInsets.all(SBBSpacing.medium),
                child: SizedBox(
                  width: 215.0,
                  height: 112.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            BoneMock.words(2),
                            style: sbbTextStyle.romanStyle.xLarge,
                          ),
                        ),
                      ),
                      Skeleton.keep(
                        child: Divider(
                          height: SBBSpacing.medium,
                          color: dividerColor,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: SBBSpacing.xSmall,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(SBBIcons.telephone_gsm_small),
                              Text(
                                BoneMock.chars(6),
                                style: sbbTextStyle.romanStyle.medium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Box 2: Main header box (Expanded, height: 144)
              Expanded(
                child: SBBContentBox(
                  padding: const EdgeInsets.all(SBBSpacing.medium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48.0,
                        child: Row(
                          children: [
                            const Icon(SBBIcons.battery_level_percentage_small),
                            const SizedBox(width: SBBSpacing.xSmall),
                            const Icon(SBBIcons.wifi_small),
                            const Spacer(),
                            Row(
                              spacing: SBBSpacing.xSmall,
                              children: const [
                                Bone.square(
                                  size: 40.0,
                                  borderRadius: BorderRadius.all(Radius.circular(SBBSpacing.small)),
                                ),
                                Bone.square(
                                  size: 40.0,
                                  borderRadius: BorderRadius.all(Radius.circular(SBBSpacing.small)),
                                ),
                                Bone.square(
                                  size: 40.0,
                                  borderRadius: BorderRadius.all(Radius.circular(SBBSpacing.small)),
                                ),
                                Bone.square(
                                  size: 40.0,
                                  borderRadius: BorderRadius.all(Radius.circular(SBBSpacing.small)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Skeleton.keep(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: SBBSpacing.xSmall),
                          child: Divider(
                            height: 1.0,
                            color: dividerColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 48.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              BoneMock.words(3),
                              style: sbbTextStyle.romanStyle.large,
                            ),
                            const Spacer(),
                            Text(
                              BoneMock.words(2),
                              style: sbbTextStyle.romanStyle.large,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Box 3: Chronograph & delay (width: 180, height: 144)
              ConstrainedBox(
                constraints: BoxConstraints.tight(const Size(180, 144)),
                child: SBBContentBox(
                  padding: const EdgeInsets.all(SBBSpacing.medium),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(SBBSpacing.xSmall),
                          child: Text(
                            BoneMock.chars(8),
                            style: sbbTextStyle.boldStyle.xLarge,
                          ),
                        ),
                      ),
                      Skeleton.keep(
                        child: Divider(
                          height: SBBSpacing.medium,
                          color: dividerColor,
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(SBBSpacing.xSmall),
                          child: Text(
                            BoneMock.chars(4),
                            style: sbbTextStyle.lightStyle.xLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
