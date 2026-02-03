import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/connectivity_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/exlamation_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ConnectivityIcon extends StatelessWidget {
  static const Key disconnectedKey = Key('disconnectedKey');
  static const Key connectedWifiKey = Key('connectedWifiKey');

  const ConnectivityIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ConnectivityViewModel>();
    final uxTestingVM = context.read<UxTestingViewModel>();

    return StreamBuilder(
      stream: Rx.combineLatest2(viewModel.model, uxTestingVM.connectivityDisplayStatus, (a, b) => (a, b)),
      initialData: (viewModel.modelValue, null),
      builder: (context, snapshot) {
        final deviceData = snapshot.data?.$1;
        final uxData = snapshot.data?.$2;

        final snapshotData = uxData ?? deviceData;

        if (snapshotData == .connected) return SizedBox.shrink();

        final isDisconnected = snapshotData == .disconnected;

        final icon = isDisconnected ? AppAssets.iconWifiDisabled : AppAssets.iconWifi;
        final onTap = isDisconnected ? () => _onDisconnectedTap(context) : () => _onConnectedWifiTap(context);
        final key = isDisconnected ? disconnectedKey : connectedWifiKey;

        return ExclamationIconButton(icon: icon, onTap: onTap, key: key);
      },
    );
  }

  void _onConnectedWifiTap(BuildContext context) {
    showSBBModalSheet(
      context: context,
      title: '',
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding: const .all(SBBSpacing.medium),
        child: SBBMessage(
          title: context.l10n.w_modal_sheet_disconnected_wifi_message_title,
          description: context.l10n.w_modal_sheet_disconnected_wifi_message_text,
          illustration: MessageIllustration.Man,
        ),
      ),
    );
  }

  void _onDisconnectedTap(BuildContext context) {
    showSBBModalSheet(
      context: context,
      title: '',
      constraints: BoxConstraints(minWidth: double.infinity),
      child: Padding(
        padding: const .all(SBBSpacing.medium),
        child: SBBMessage(
          title: context.l10n.w_modal_sheet_disconnected_message_title,
          description: context.l10n.w_modal_sheet_disconnected_message_text,
          illustration: MessageIllustration.Display,
        ),
      ),
    );
  }
}
