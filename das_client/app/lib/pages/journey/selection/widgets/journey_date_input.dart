import 'package:app/pages/journey/selection/model/journey_selection_model.dart';
import 'package:app/pages/journey/selection/view_model/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_field_bottom_modal.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_field_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JourneyDateInput extends StatelessWidget {
  const JourneyDateInput({
    super.key,
    this.isModalVersion = false,
  });

  final bool isModalVersion;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;

        final onSelect = switch (model) {
          final Selecting _ || final Error _ => viewModel.updateDate,
          _ => null,
        };

        return isModalVersion
            ? JourneyDateFieldBottomModal(
                onSelect: onSelect,
                date: model.startDate,
                availableStartDates: model.availableStartDates,
              )
            : JourneyDateFieldOverlay(
                onSelect: onSelect,
                date: model.startDate,
                availableStartDates: model.availableStartDates,
              );
      },
    );
  }
}
