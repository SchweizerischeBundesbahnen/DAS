import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/journey_filter_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/reduced_overview_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/reduced_journey_table.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showReducedOverviewModalSheet(BuildContext context) async {
  final viewModel = DI.get<JourneyViewModel>();
  final trainIdentification = viewModel.journeyValue?.metadata.trainIdentification;
  if (trainIdentification == null) return;

  final locale = Localizations.localeOf(context);

  final title =
      '${context.l10n.w_reduced_journey_table_title}: '
      '${viewModel.formattedTrainIdentifierValue}, '
      '${Format.dateWithAbbreviatedDay(trainIdentification.date, locale)}';

  return showSBBBottomSheet(
    context: context,
    titleText: title,
    scrollControlDisabledMaxHeightRatio: 0.98,
    style: const SBBBottomSheetStyle(
      constraints: BoxConstraints(),
    ),
    body: MultiProvider(
      providers: [
        Provider<JourneyTableViewModel>.value(value: DI.get<JourneyTableViewModel>()),
        Provider<JourneyViewModel>.value(value: DI.get<JourneyViewModel>()),
        Provider<CollapsibleRowsViewModel>.value(value: DI.get<CollapsibleRowsViewModel>()),
        Provider<JourneyFilterViewModel>.value(value: DI.get<JourneyFilterViewModel>()),
        Provider<ArrivalDepartureTimeViewModel>(
          create: (_) => ArrivalDepartureTimeViewModel(journeyViewModel: DI.get()),
          dispose: (_, vm) => vm.dispose(),
          lazy: false,
        ),
        Provider<RouteVariantViewModel>(
          create: (_) => RouteVariantViewModel(journeyViewModel: DI.get()),
          dispose: (_, vm) => vm.dispose(),
          lazy: false,
        ),

        ProxyProvider2<RouteVariantViewModel, CollapsibleRowsViewModel, ReducedOverviewViewModel>(
          lazy: false,
          update: (_, routeVariantVM, collapsibleRowsVM, prev) {
            if (prev != null) return prev;
            return ReducedOverviewViewModel(
              journeyViewModel: DI.get(),
              routeVariantViewModel: routeVariantVM,
              collapsibleRowsViewModel: collapsibleRowsVM,
              journeyFilterViewModel: DI.get(),
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
      ],
      child: _ReducedOverviewModalSheet(),
    ),
  );
}

class _ReducedOverviewModalSheet extends StatelessWidget {
  const _ReducedOverviewModalSheet();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .max,
      spacing: SBBSpacing.xSmall,
      children: [
        Expanded(child: ReducedJourneyTable()),
      ],
    );
  }
}
