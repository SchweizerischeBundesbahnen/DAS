import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/brake_series_selection_button.dart';
import 'package:app/pages/journey/journey_validation/journey_validation_view_model.dart';
import 'package:app/pages/journey/journey_validation/multi_brake_series_selection_model.dart';
import 'package:app/util/animation.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class MultiBrakeSeriesSelection extends StatefulWidget {
  const MultiBrakeSeriesSelection({super.key});

  @override
  State<MultiBrakeSeriesSelection> createState() => _MultiBrakeSeriesSelectionState();
}

class _MultiBrakeSeriesSelectionState extends State<MultiBrakeSeriesSelection> {
  final _viewModel = DI.get<JourneyValidationViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.startBrakeSeriesEditing();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MultiBrakeSeriesSelectionModel>(
      initialData: _viewModel.editingBrakeSeriesModelValue,
      stream: _viewModel.editingBrakeSeriesModel,
      builder: (context, snap) {
        final model = snap.requireData;
        if (model.availableBrakeSeries.isEmpty) return _noAvailableBrakeSeriesView(context);

        return Column(
          mainAxisSize: .min,
          children: [
            SingleChildScrollView(
              child: SBBContentBox(
                padding: const .symmetric(horizontal: SBBSpacing.medium),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    children: _rows(context, model),
                  ),
                ),
              ),
            ),
            _confirmButton(context),
          ],
        );
      },
    );
  }

  Widget _confirmButton(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: SBBSpacing.medium),
      child: SBBPrimaryButton(
        labelText: context.l10n.c_button_confirm,
        onPressed: _viewModel.editingBrakeSeriesModelValue.selectedBrakeSeries.isNotEmpty
            ? () {
                _viewModel.saveBrakeSeriesSelection();
                Navigator.of(context).pop(_viewModel.brakeSeriesModelValue.selectedBrakeSeries.firstOrNull);
              }
            : null,
      ),
    );
  }

  Widget _noAvailableBrakeSeriesView(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(context.l10n.p_journey_brake_series_empty),
      ),
    );
  }

  List<Widget> _rows(BuildContext context, MultiBrakeSeriesSelectionModel model) {
    return model.availableBrakeSeries
        .map((it) => it.trainSeries)
        .toSet()
        .sorted(_sortForSelectionDisplay)
        .map((it) => _trainSeriesRows(context, model, it))
        .expand((it) => it)
        .toList();
  }

  List<Widget> _trainSeriesRows(BuildContext context, MultiBrakeSeriesSelectionModel model, TrainSeries trainSeries) {
    final brakeSeries = model.availableBrakeSeries.where((it) => it.trainSeries == trainSeries).toList();
    brakeSeries.sort((a, b) => b.brakedWeightPercentage.compareTo(a.brakedWeightPercentage));

    return [
      Padding(
        padding: const .symmetric(vertical: SBBSpacing.medium),
        child: Text(
          trainSeries.name,
          style: sbbTextStyle.boldStyle.medium,
        ),
      ),
      Padding(
        padding: const .only(bottom: SBBSpacing.medium),
        child: Wrap(
          spacing: SBBSpacing.small,
          runSpacing: SBBSpacing.medium,
          children: List.generate(
            brakeSeries.length,
            (index) {
              final thisBrakeSeries = brakeSeries[index];
              final isAllowed = model.allowedBrakeSeries.contains(thisBrakeSeries);
              return IgnorePointer(
                ignoring: !isAllowed,
                child: AnimatedOpacity(
                  duration: DASAnimation.shortDuration,
                  opacity: isAllowed ? 1.0 : 0.4,
                  child: BrakeSeriesSelectionButton(
                    label: thisBrakeSeries.name,
                    currentlySelected: model.selectedBrakeSeries.contains(thisBrakeSeries),
                    onTap: () => _viewModel.toggleBrakeSeriesSelection(thisBrakeSeries),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  int _sortForSelectionDisplay(TrainSeries a, TrainSeries b) {
    int getOrder(TrainSeries trainSeries) => switch (trainSeries) {
      .R => 0,
      .A => 1,
      .D => 2,
      .N => 3,
      .O => 4,
      .W => 5,
      .S => 6,
    };

    return getOrder(a).compareTo(getOrder(b));
  }
}
