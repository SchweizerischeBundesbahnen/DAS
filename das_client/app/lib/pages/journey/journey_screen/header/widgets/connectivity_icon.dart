import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/connectivity_view_model.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/exclamation_icon_button.dart';
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
        final snapshotData = snapshot.data;

        if (snapshotData == .connected) return SizedBox.shrink();

        final isDisconnected = snapshotData == .disconnected;
        return ExclamationIconButton(
          key: isDisconnected ? disconnectedKey : connectedWifiKey,
          icon: isDisconnected ? AppAssets.iconWifiDisabled : AppAssets.iconWifi,
          onTap: isDisconnected ? () => _onDisconnectedTap(context) : () => _onConnectedWifiTap(context),
        );
      },
    );
  }

  void _onConnectedWifiTap(BuildContext context) => _showMessageSheet(
    context,
    title: context.l10n.w_modal_sheet_disconnected_wifi_message_title,
    subtitle: context.l10n.w_modal_sheet_disconnected_wifi_message_text,
  );

  void _onDisconnectedTap(BuildContext context) => _showMessageSheet(
    context,
    title: context.l10n.w_modal_sheet_disconnected_message_title,
    subtitle: context.l10n.w_modal_sheet_disconnected_message_text,
  );

  void _showMessageSheet(BuildContext context, {required String title, required String subtitle}) {
    showSBBBottomSheet(
      context: context,
      style: const SBBBottomSheetStyle(
        constraints: BoxConstraints(minWidth: double.infinity),
      ),
      body: Center(
        heightFactor: 1,
        child: SBBMessage(
          titleText: title,
          subtitleText: subtitle,
          illustration: SBBIllustration.display(),
        ),
      ),
    );
  }
}
