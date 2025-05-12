import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdditionalSpeedRestrictionModalBuilder extends DASModalSheetBuilder {
  @override
  Widget body(BuildContext context) {
    return Placeholder();
  }

  @override
  Widget header(BuildContext context) {
    final viewModel = context.read<AdditionalSpeedRestrictionModalViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.w_additional_speed_restriction_modal_title, style: DASTextStyles.largeRoman),
        StreamBuilder(
          stream: viewModel.count,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            final countLabel = context.l10n.w_additional_speed_restriction_modal_subtitle_count;
            return Text('$countLabel: $count', style: DASTextStyles.extraSmallRoman);
          },
        ),
      ],
    );
  }
}
