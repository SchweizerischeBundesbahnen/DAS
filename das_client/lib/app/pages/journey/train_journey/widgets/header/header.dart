import 'package:das_client/app/pages/journey/train_journey/widgets/header/main_container.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:das_client/app/widgets/extended_header_container.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return ExtendedAppBarWrapper(
      child: Padding(
        padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5).copyWith(top: 0),
        child: Row(
          spacing: sbbDefaultSpacing * 0.5,
          children: [
            Expanded(child: MainContainer()),
            TimeContainer(),
          ],
        ),
      ),
    );
  }
}
