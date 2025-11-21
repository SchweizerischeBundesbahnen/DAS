import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DetailModalSheet extends StatelessWidget {
  const DetailModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DetailModalViewModel>();
    return StreamBuilder(
      stream: viewModel.contentBuilder,
      builder: (context, snapshot) {
        return DasModalSheet(
          controller: viewModel.controller,
          leftMargin: sbbDefaultSpacing * 0.5,
          builder: snapshot.data ?? DASModalSheetBuilder(),
        );
      },
    );
  }
}
