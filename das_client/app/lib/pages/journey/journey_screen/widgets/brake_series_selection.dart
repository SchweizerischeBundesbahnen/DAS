import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/brake_series_selection_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class BrakeSeriesSelection extends StatefulWidget {
  const BrakeSeriesSelection({required this.availableBrakeSeries, required this.selectedBrakeSeries, super.key});

  final Set<BrakeSeries> availableBrakeSeries;
  final BrakeSeries? selectedBrakeSeries;

  @override
  State<BrakeSeriesSelection> createState() => _BrakeSeriesSelectionState();
}

class _BrakeSeriesSelectionState extends State<BrakeSeriesSelection> {
  BrakeSeries? selectedBrakeSeries;

  @override
  void initState() {
    selectedBrakeSeries = widget.selectedBrakeSeries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableBrakeSeries.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(context.l10n.p_journey_brake_series_empty),
        ),
      );
    }

    return Padding(
      padding: const .fromLTRB(SBBSpacing.medium, 0, SBBSpacing.medium, 21),
      child: SBBContentBox(
        padding: const .symmetric(horizontal: SBBSpacing.medium),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: _rows(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _rows(BuildContext context) {
    return widget.availableBrakeSeries
        .map((it) => it.trainSeries)
        .toSet()
        .sorted(_sortForSelectionDisplay)
        .map((it) => _trainSeriesRows(context, it))
        .expand((it) => it)
        .toList();
  }

  List<Widget> _trainSeriesRows(BuildContext context, TrainSeries trainSeries) {
    final brakeSeries = widget.availableBrakeSeries.where((it) => it.trainSeries == trainSeries).toList();
    brakeSeries.sort((a, b) => b.brakeSeries.compareTo(a.brakeSeries));

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
              final brakeSerie = brakeSeries[index];
              return BrakeSeriesSelectionButton(
                label: brakeSerie.name,
                currentlySelected: brakeSerie == selectedBrakeSeries,
                onTap: () {
                  setState(() {
                    context.router.maybePop(brakeSerie);
                  });
                },
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
