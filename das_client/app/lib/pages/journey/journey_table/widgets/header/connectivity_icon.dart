import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/header/connectivity/connectivity_view_model.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/exlamation_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ConnectivityIcon extends StatelessWidget {
  static const Key disconnectedKey = Key('disconnectedKey');
  static const Key connectedWifiKey = Key('connectedWifiKey');

  const ConnectivityIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ConnectivityViewModel>();

    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityDisplayStatus.connected) return SizedBox.shrink();

        final isDisconnected = snapshot.data == ConnectivityDisplayStatus.disconnected;

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
        padding: const EdgeInsets.all(sbbDefaultSpacing),
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
        padding: const EdgeInsets.all(sbbDefaultSpacing),
        child: SBBMessage(
          title: context.l10n.w_modal_sheet_disconnected_message_title,
          description: context.l10n.w_modal_sheet_disconnected_message_text,
          illustration: MessageIllustration.Display,
        ),
      ),
    );
  }
}
