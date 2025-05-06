import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/bloc/ux_testing_cubit.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/koa_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:app/pages/journey/train_journey/widgets/warn_function_modal_sheet.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/di.dart';
import 'package:app/util/sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sfera/component.dart';

class TrainJourneyOverview extends StatelessWidget {
  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;
    return Provider(
      create: (_) => DetailModalSheetViewModel(
        onOpen: () => bloc.automaticAdvancementController.resetScrollTimer(),
      ),
      dispose: (context, vm) => vm.dispose(),
      builder: (context, child) => BlocProvider.value(
        value: DI.get<UxTestingCubit>(),
        child: BlocListener<UxTestingCubit, UxTestingState>(
          listener: _handleUxEvents,
          child: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final detailModalSheetController = context.read<DetailModalSheetViewModel>().controller;
    return Listener(
      onPointerDown: (_) => detailModalSheetController.resetAutomaticClose(),
      onPointerUp: (_) => detailModalSheetController.resetAutomaticClose(),
      child: Row(
        children: [
          Expanded(child: _content()),
          DetailModalSheet(),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      children: [
        Header(),
        ManeuverNotification(),
        KoaNotification(),
        Expanded(child: TrainJourney()),
      ],
    );
  }

  void _handleUxEvents(BuildContext context, UxTestingState state) {
    if (state is UxTestingEventReceived) {
      if (state.event.isWarn) {
        Sound.play(AppAssets.warnappWarn);
        showWarnFunctionModalSheet(context);
      } else if (state.event.isKoa && state.event.value == KoaState.waitCancelled.name) {
        Sound.play(AppAssets.soundKoaWaitCanceled);
      }
    }
  }
}
