import 'package:app/pages/journey/journey_table/header/radio_channel/radio_channel_view_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/header/departure_authorization.dart';
import 'package:app/pages/journey/journey_table/widgets/header/journey_identifier.dart';
import 'package:app/pages/journey/journey_table/widgets/header/radio_channel.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:skeletonizer/skeletonizer.dart';

const double _width = 230.0;
const double _height = 112.0;

class HeaderBox extends StatelessWidget {
  static const Key punctualityTextKey = Key('punctualityTextKey');
  static const Key currentTimeTextKey = Key('currentTimeTextKey');

  const HeaderBox({super.key});

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
    return SBBGroup(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      child: SizedBox(
        width: _width,
        height: _height,
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Flexible(child: JourneyIdentifier()),
      Divider(height: sbbDefaultSpacing, color: SBBColors.cloud),
      Flexible(child: _bottomHeaderRow()),
    ],
  );

  Widget _bottomHeaderRow() => SizedBox(
    height: 48.0,
    child: RadioChannel(),
  );
}
