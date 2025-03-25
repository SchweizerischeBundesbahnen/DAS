import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignalRow extends CellRowBuilder<Signal> {
  static const Key signalLineChangeIconKey = Key('signalLineChangeIcon');

  const SignalRow({
    required super.metadata,
    required super.data,
    super.config,
  });

  @override
  DASTableCell informationCell(BuildContext context) {
    return DASTableCell(
      child: Row(
        children: [
          _signalFunctions(context),
          Spacer(),
          if (data.visualIdentifier != null) Text(data.visualIdentifier!),
        ],
      ),
    );
  }

  /// Signal functions displayed as string. Type [SignalFunction.laneChange] is ignored if other functions are given as this is displayed with an icon.
  Widget _signalFunctions(BuildContext context) {
    Iterable<SignalFunction> signalFunctions = data.functions;
    if (signalFunctions.length > 1) {
      signalFunctions = signalFunctions
          .where((function) => function != SignalFunction.laneChange && function != SignalFunction.unknown);
    }
    return Text(signalFunctions.map((function) => function.localizedName(context)).join('/'));
  }

  @override
  DASTableCell iconsCell1(BuildContext context) {
    if (data.functions.contains(SignalFunction.laneChange)) {
      return DASTableCell(
        child: SvgPicture.asset(
          key: signalLineChangeIconKey,
          AppAssets.iconSignalLaneChange,
          colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
        ),
        alignment: Alignment.center,
      );
    }
    return DASTableCell.empty();
  }
}

// extensions

extension _SignalFunctionExtension on SignalFunction {
  String localizedName(BuildContext context) {
    switch (this) {
      case SignalFunction.entry:
        return context.l10n.c_main_signal_function_entry;
      case SignalFunction.block:
        return context.l10n.c_main_signal_function_block;
      case SignalFunction.exit:
        return context.l10n.c_main_signal_function_exit;
      case SignalFunction.laneChange:
        return context.l10n.c_main_signal_function_laneChange;
      case SignalFunction.intermediate:
        return context.l10n.c_main_signal_function_intermediate;
      case SignalFunction.protection:
        return context.l10n.c_main_signal_function_protection;
      case SignalFunction.unknown:
        return context.l10n.c_unknown;
    }
  }
}
