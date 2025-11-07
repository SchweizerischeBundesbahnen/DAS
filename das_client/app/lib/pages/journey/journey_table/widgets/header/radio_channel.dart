import 'package:app/pages/journey/journey_table/header/radio_channel/radio_channel_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/header/radio_contact.dart';
import 'package:app/pages/journey/journey_table/widgets/header/sim_identifier.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class RadioChannel extends StatelessWidget {
  const RadioChannel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RadioChannelViewModel>();
    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null) return SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            final viewModel = context.read<ServicePointModalViewModel>();
            viewModel.open(context, tab: ServicePointModalTab.communication, servicePoint: model.lastServicePoint);
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: DotIndicator(
              show: model.showDotIndicator,
              offset: Offset(-6.0, -8.0),
              child: Row(
                spacing: sbbDefaultSpacing * 0.5,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(SBBIcons.telephone_gsm_small),
                  RadioContactChannels(mainContactIdentifiers: model.mainContactsIdentifier),
                  if (model.networkType == CommunicationNetworkType.sim) SimIdentifier(),
                  if (model.networkType != null && model.networkType != CommunicationNetworkType.sim)
                    CommunicationNetworkIcon(networkType: model.networkType!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
