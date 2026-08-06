import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/radio_channel_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/radio_contact.dart';
import 'package:app/pages/journey/journey_screen/widgets/communication_network_icon.dart';
import 'package:app/widgets/das_badge_overlay.dart';
import 'package:app/widgets/das_circle_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

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
            viewModel.open(context, tab: .communication, servicePoint: model.lastServicePoint);
          },
          child: Align(
            alignment: .centerRight,
            child: DASBadgeOverlay(
              badgeVisible: model.showDotIndicator,
              badgeOffset: Offset(-6.0, -8.0),
              badge: const DASCircleBadge(),
              child: Row(
                spacing: SBBSpacing.xSmall,
                crossAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  const Icon(SBBIcons.telephone_gsm_small),
                  Flexible(child: RadioContactChannels(mainContactIdentifiers: model.mainContactsIdentifier)),
                  if (model.networkType != null) CommunicationNetworkIcon(networkType: model.networkType!),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
