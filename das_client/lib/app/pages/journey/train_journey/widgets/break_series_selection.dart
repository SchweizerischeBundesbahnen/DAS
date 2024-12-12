import 'package:auto_route/auto_route.dart';
import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/break_series_selection_button.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/train_series.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class BreakSeriesSelection extends StatefulWidget {
  const BreakSeriesSelection({required this.availableBreakSeries, required this.selectedBreakSeries, super.key});

  final Set<BreakSeries> availableBreakSeries;
  final BreakSeries selectedBreakSeries;

  @override
  State<BreakSeriesSelection> createState() => _BreakSeriesSelectionState();
}

class _BreakSeriesSelectionState extends State<BreakSeriesSelection> {
  late BreakSeries selectedBreakSeries;

  @override
  void initState() {
    selectedBreakSeries = widget.selectedBreakSeries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, sbbDefaultSpacing, 21),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, sbbDefaultSpacing, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _rows(context),
              ),
            ),
          ),
          SizedBox(height: 46),
          SBBPrimaryButton(label: context.l10n.c_button_confirm, onPressed: () {
            context.router.maybePop(selectedBreakSeries);
          })
        ],
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
        padding: const EdgeInsets.fromLTRB(0, sbbDefaultSpacing, 0, sbbDefaultSpacing),
        child: Text(
          trainSeries.name,
          style: SBBTextStyles.mediumBold,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, sbbDefaultSpacing),
        child: Row(
          children: List.generate(
            breakSeries.length,
            (index) {
              final breakSerie = breakSeries[index];
              return BreakSeriesSelectionButton(
                  label: breakSerie.toString(),
                  currentlySelected: breakSerie == selectedBreakSeries,
                  onTap: () {
                    setState(() {
                      selectedBreakSeries = breakSerie;
                    });
                  });
            },
          ),
        ),
      ),
    ];
  }
}
