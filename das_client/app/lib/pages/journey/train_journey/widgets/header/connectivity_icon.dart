import 'package:app/pages/journey/train_journey/header/connectivity/connectivity_view_model.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/exlamation_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityIcon extends StatelessWidget {
  static const Key disconnectedKey = Key('disconnectedKey');
  static const Key disconnectedWifiKey = Key('disconnectedWifiKey');

  const ConnectivityIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ConnectivityViewModel>();

    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        if (snapshot.data == ConnectivityDisplayStatus.connected) return SizedBox.shrink();

        final icon = snapshot.data == ConnectivityDisplayStatus.disconnected
            ? AppAssets.iconWifi
            : AppAssets.iconWifiDisabled;
        final onTap = snapshot.data == ConnectivityDisplayStatus.disconnected
            ? _onDisconnectedTap
            : _onDisconnectedWifiTap;
        final key = snapshot.data == ConnectivityDisplayStatus.disconnected ? disconnectedKey : disconnectedWifiKey;

        return Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ExclamationIconButton(icon: icon, onTap: onTap, key: key),
        );
      },
    );
  }

  void _onDisconnectedWifiTap() {}

  void _onDisconnectedTap() {}
}
