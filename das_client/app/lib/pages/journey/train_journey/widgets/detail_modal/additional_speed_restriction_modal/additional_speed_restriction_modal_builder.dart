import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/details_table.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class AdditionalSpeedRestrictionModalBuilder extends DASModalSheetBuilder {
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

  @override
  Widget body(BuildContext context) {
    final viewModel = context.read<AdditionalSpeedRestrictionModalViewModel>();
    return StreamBuilder(
      stream: viewModel.additionalSpeedRestriction,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SBBLoadingIndicator.tiny();
        }

        final restriction = snapshot.requireData;
        final fromKilometre = restriction.kmFrom.toStringAsFixed(3);
        final endKilometre = restriction.kmTo.toStringAsFixed(3);

        final data = {
          context.l10n.w_additional_speed_restriction_modal_table_label_km: '$fromKilometre - $endKilometre',
          context.l10n.w_additional_speed_restriction_modal_table_label_vmax: restriction.speed?.toString(),
          context.l10n.w_additional_speed_restriction_modal_table_label_from: restriction.restrictionFrom?.format(),
          context.l10n.w_additional_speed_restriction_modal_table_label_until: restriction.restrictionUntil?.format(),
          context.l10n.w_additional_speed_restriction_modal_table_label_reason: restriction.reason?.localized,
        };

        return SingleChildScrollView(child: DetailsTable(data: data));
      },
    );
  }
}

extension _DateTimeFormat on DateTime {
  String format() => DateFormat('DD.MM.yyyy HH:MM').format(this);
}
