import 'package:app/pages/journey/journey_table/header/radio_channel/radio_channel_view_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/header/journey_identifier.dart';
import 'package:app/pages/journey/journey_table/widgets/header/radio_channel.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:skeletonizer/skeletonizer.dart';

const double _width = 215.0;
const double _smallWidth = 150.0;
const double _height = 112.0;

class JourneyIdentifierHeaderBox extends StatelessWidget {
  const JourneyIdentifierHeaderBox({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyViewModel = context.read<JourneyTableViewModel>();
    final journeyPositionViewModel = context.read<JourneyPositionViewModel>();

    return Provider(
      create: (_) => RadioChannelViewModel(
        journeyStream: journeyViewModel.journey,
        journeyPositionStream: journeyPositionViewModel.model,
      ),
      dispose: (_, vm) => vm.dispose(),
      child: StreamBuilder(
        stream: journeyViewModel.journey,
        builder: (context, snapshot) {
          final isLoading = !snapshot.hasData;
          return Skeletonizer(
            enabled: isLoading,
            child: _content(context),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    final viewModel = context.read<DetailModalViewModel>();
    return StreamBuilder<bool>(
      stream: viewModel.isModalOpen,
      initialData: viewModel.isModalOpenValue,
      builder: (context, asyncSnapshot) {
        final isModalOpen = asyncSnapshot.requireData;

        return SBBGroup(
          padding: const .all(sbbDefaultSpacing),
          child: SizedBox(
            width: isModalOpen ? _smallWidth : _width,
            height: _height,
            child: _body(context),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context) => Column(
    mainAxisAlignment: .start,
    crossAxisAlignment: .end,
    children: [
      Expanded(child: JourneyIdentifier()),
      Divider(height: sbbDefaultSpacing, color: SBBColors.cloud),
      Expanded(child: _radioChannel()),
    ],
  );

  Widget _radioChannel() => SizedBox(
    height: 48.0,
    child: RadioChannel(),
  );
}
