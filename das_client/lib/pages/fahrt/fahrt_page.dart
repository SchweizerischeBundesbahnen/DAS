import 'package:auto_route/auto_route.dart';
import 'package:das_client/auth/auth_cubit.dart';
import 'package:das_client/bloc/fahrbild_cubit.dart';
import 'package:das_client/di.dart';
import 'package:das_client/i18n/src/build_context_x.dart';
import 'package:das_client/nav/app_router.dart';
import 'package:das_client/nav/das_navigation_drawer.dart';
import 'package:das_client/pages/fahrt/widgets/fahrbild.dart';
import 'package:das_client/pages/fahrt/widgets/train_selection.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FahrtPage extends StatelessWidget {
  const FahrtPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FahrbildCubit(sferaService: DI.get()),
      child: FahrtPageContent(),
    );
  }
}

class FahrtPageContent extends StatelessWidget {
  const FahrtPageContent({super.key});

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
            if (context.fahrbildCubit.state is SelectingFahrbildState) {
              context.authCubit.logout();
              context.router.replace(const LoginRoute());
            } else {
              context.fahrbildCubit.reset();
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
    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      child: BlocBuilder<FahrbildCubit, FahrbildState>(
        builder: (context, state) {
          if (state is SelectingFahrbildState) {
            return const TrainSelection();
          } else if (state is FahrbildLoadedState) {
            return const Fahrbild();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
