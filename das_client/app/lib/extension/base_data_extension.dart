import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

extension BaseDataExtension on BaseData {
  double get chevronPosition {
    if (this is ServicePoint) {
      final servicePoint = this as ServicePoint;
      return ServicePointRow.baseRowHeight -
          sbbDefaultSpacing -
          RouteCellBody.chevronHeight -
          (servicePoint.isStop ? RouteCellBody.routeCircleSize : 0.0);
    } else {
      return CellRowBuilder.rowHeight - sbbDefaultSpacing - RouteCellBody.chevronHeight;
    }
  }
}
