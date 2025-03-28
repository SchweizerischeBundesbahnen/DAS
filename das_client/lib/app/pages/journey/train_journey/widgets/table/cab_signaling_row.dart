import 'package:das_client/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CABSignalingRow extends CellRowBuilder<CABSignaling> {
  static const Key cabSignalingStartIconKey = Key('cabSignalingStartIcon');
  static const Key cabSignalingEndIconKey = Key('cabSignalingEndIcon');

  const CABSignalingRow({
    required super.metadata,
    required super.data,
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
}
