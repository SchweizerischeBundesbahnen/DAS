import 'package:auto_route/auto_route.dart';
import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/di.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:das_client/app/nav/das_navigation_drawer.dart';
import 'package:das_client/app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:das_client/app/pages/journey/train_selection/train_selection.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainJourneyCubit(sferaService: DI.get()),
      child: const JourneyPageContent(),
    );
  }
}

class JourneyPageContent extends StatelessWidget {
  const JourneyPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
      drawer: const DASNavigationDrawer(),
    );
  }

  SBBHeader _appBar(BuildContext context) {
    return SBBHeader(
      title: context.l10n.c_app_name,
      actions: [
        IconButton(
          icon: const Icon(SBBIcons.exit_small),
          onPressed: () {
            if (context.trainJourneyCubit.state is SelectingTrainJourneyState) {
              context.authCubit.logout();
              context.router.replace(const LoginRoute());
            } else {
              context.trainJourneyCubit.reset();
            }
          },
        )
      ],
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _content()),
      ],
    );
  }

  Widget _content() {
    return BlocBuilder<TrainJourneyCubit, TrainJourneyState>(
      builder: (context, state) {
        if (state is SelectingTrainJourneyState) {
          return const TrainSelection();
        } else if (state is TrainJourneyLoadedState) {
          return const TrainJourneyOverview();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}