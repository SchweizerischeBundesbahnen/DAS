import 'package:das_client/pages/fahrbild/widgets/header/button_area.dart';
import 'package:das_client/pages/fahrbild/widgets/header/next_stop.dart';
import 'package:das_client/pages/fahrbild/widgets/header/punctuality_display.dart';
import 'package:das_client/pages/fahrbild/widgets/header/radio_channel.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _background(context),
        _group(context),
      ],
    );
  }

  Widget _background(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    return Container(
      color: primary,
      height: 16.0,
    );
  }

  Widget _group(BuildContext context) {
    return SBBGroup(
      margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
      padding: const EdgeInsets.all(16).copyWith(bottom: 8.0),
      useShadow: true,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _topHeaderRow(),
            _divider(),
            _bottomHeaderRow(),
          ],
        ),
      ),
    );
  }

  Widget _bottomHeaderRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          RadioChannel(),
          SizedBox(width: 48.0),
          NextStop(),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(height: 1.0, color: SBBColors.cloud),
    );
  }

  Widget _topHeaderRow() {
    return const Row(
      children: [
        Expanded(
          child: PunctualityDisplay(),
        ),
        ButtonArea(),
      ],
    );
  }
}
