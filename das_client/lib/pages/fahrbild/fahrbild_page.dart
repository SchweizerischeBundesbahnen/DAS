import 'package:auto_route/auto_route.dart';
import 'package:das_client/bloc/fahrbild_cubit.dart';
import 'package:das_client/nav/app_router.dart';
import 'package:das_client/nav/das_navigation_drawer.dart';
import 'package:das_client/pages/fahrbild/widgets/fahrbild.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO: discuss general naming in DEV team
@RoutePage()
class FahrbildPage extends StatelessWidget {
  const FahrbildPage({super.key});

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
      title: 'Fahrbild',
      // TODO: Workaround as otherwise the SBB logo is shown
      actions: const [SizedBox.shrink()],
      leadingWidget: Builder(
        builder: (context) => IconButton(
          icon: const Icon(SBBIcons.hamburger_menu_small),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
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
    return BlocBuilder<FahrbildCubit, FahrbildState>(
      builder: (context, state) {
        if (state is FahrbildLoadedState) {
          return const Fahrbild();
        } else if (state is FahrbildLoadedState) {
          // TODO: unsexy, as Listener doesn't use initial state.
          context.router.replace(const TrainSelectionRoute());
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
