import 'package:app/pages/journey/journey_table/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sfera/component.dart';

class CABSignalingRow extends CellRowBuilder<CABSignaling> {
  static const Key cabSignalingStartIconKey = Key('cabSignalingStartIcon');
  static const Key cabSignalingEndIconKey = Key('cabSignalingEndIcon');

  CABSignalingRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required super.journeyPosition,
    super.config,
  });

  @override
  DASTableCell iconsCell1(BuildContext context) {
    return DASTableCell(
      child: SvgPicture.asset(
        key: data.isStart ? cabSignalingStartIconKey : cabSignalingEndIconKey,
        data.isStart ? AppAssets.iconCabStart : AppAssets.iconCabEnd,
        colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
      ),
      alignment: Alignment.center,
    );
  }

  @override
  ShowSpeedBehavior get showSpeedBehavior => .always;
}
