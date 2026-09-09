import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/model/journey_filter_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/journey_filter_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class const FilterBar({required final JourneyFilterModel model, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .start,
      mainAxisSize: .max,
      spacing: SBBSpacing.xSmall,
      children: [
        ?_filterButton(context, label: context.l10n.w_filter_bar_option_indications, filter: model.indication),
        ?_filterButton(
          context,
          label: context.l10n.w_filter_bar_option_protection_sections,
          filter: model.protectionSections,
        ),
        ?_filterButton(
          context,
          label: context.l10n.w_filter_bar_option_addition_speed_restrictions,
          filter: model.additionalSpeedRestrictions,
        ),
        ?_filterButton(
          context,
          label: context.l10n.w_filter_bar_option_short_term_changes,
          filter: model.shortTermChanges,
        ),
        ?_filterButton(context, label: context.l10n.w_filter_bar_option_modifications, filter: model.modifications),
        Spacer(),
        _resetButton(context),
      ],
    );
  }

  Widget? _filterButton(
    BuildContext context, {
    required String label,
    required FilterOption filter,
  }) {
    if (filter.affectedData.isEmpty) return null;
    final viewModel = context.read<JourneyFilterViewModel>();

    return SBBChip(
      selected: !filter.active,
      labelText: label,
      trailingText: filter.affectedData.length.toString(),
      onChanged: (_) => viewModel.toggleFilter(filter),
    );
  }

  Widget _resetButton(BuildContext context) {
    final viewModel = context.read<JourneyFilterViewModel>();

    return SBBTertiaryButtonSmall(
      labelText: context.l10n.w_filter_bar_reset_button,
      onPressed: () => viewModel.resetFilters(),
    );
  }
}
