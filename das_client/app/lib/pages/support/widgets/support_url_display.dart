import 'package:app/i18n/i18n.dart';
import 'package:flutter/widgets.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SupportUrlDisplay extends StatelessWidget {
  const SupportUrlDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: SBBSpacing.xSmall,
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        SBBListHeader(
          context.l10n.p_support_url_display_title,
          style: SBBListHeaderStyle(padding: .only(left: SBBSpacing.medium)),
        ),
        SBBListItemBoxed(
          titleText: context.l10n.p_support_url_display_app_update_launcher_title,
          leadingIconData: SBBIcons.circle_information_small,
          onTap: () {},
        ),
        SBBListItemBoxed(
          titleText: context.l10n.p_support_url_display_feedback_channel_launcher_title,
          leadingIconData: SBBIcons.question_answer_small,
          onTap: () {},
        ),
        SBBListItemBoxed(
          titleText: context.l10n.p_support_url_display_privacy_policy_launcher_title,
          leadingIconData: SBBIcons.paragraph_small,
          onTap: () {},
        ),
      ],
    );
  }
}
