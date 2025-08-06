import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/break_series_selection_button.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class BreakSeriesSelection extends StatefulWidget {
  const BreakSeriesSelection({required this.availableBreakSeries, required this.selectedBreakSeries, super.key});

  final Set<BreakSeries> availableBreakSeries;
  final BreakSeries? selectedBreakSeries;

  @override
  State<BreakSeriesSelection> createState() => _BreakSeriesSelectionState();
}

class _BreakSeriesSelectionState extends State<BreakSeriesSelection> {
  BreakSeries? selectedBreakSeries;

  @override
  void initState() {
    selectedBreakSeries = widget.selectedBreakSeries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.availableBreakSeries.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(context.l10n.p_train_journey_break_series_empty),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, sbbDefaultSpacing, 21),
      child: SBBGroup(
        padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _rows(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _rows(BuildContext context) {
    return widget.availableBreakSeries
        .map((it) => it.trainSeries)
        .toSet()
        .map((it) => _trainSeriesRows(context, it))
        .expand((it) => it)
        .toList();
  }

  List<Widget> _trainSeriesRows(BuildContext context, TrainSeries trainSeries) {
    final breakSeries = widget.availableBreakSeries.where((it) => it.trainSeries == trainSeries).toList();
    breakSeries.sort((a, b) => a.breakSeries.compareTo(b.breakSeries));

    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing),
        child: Text(
          trainSeries.name,
          style: DASTextStyles.mediumBold,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: sbbDefaultSpacing),
        child: Wrap(
          spacing: sbbDefaultSpacing * 0.75,
          runSpacing: sbbDefaultSpacing,
          children: List.generate(
            breakSeries.length,
            (index) {
              final breakSerie = breakSeries[index];
              return BreakSeriesSelectionButton(
                label: breakSerie.toString(),
                currentlySelected: breakSerie == selectedBreakSeries,
                onTap: () {
                  setState(() {
                    context.router.maybePop(breakSerie);
                  });
                },
              );
            },
          ),
        ),
      ),
    ];
  }
}
