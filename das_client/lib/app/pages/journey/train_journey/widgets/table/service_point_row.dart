import 'package:das_client/app/widgets/table/das_table_cell.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

// TODO: Extract real values from SFERA objects.
@immutable
class ServicePointRow extends DASTableRowBuilder {
  const ServicePointRow({
    this.timingPoint,
    this.timingPointConstraints,
    this.active = false,
    super.height = 64.0,
  });

  final TimingPoint? timingPoint;
  final TimingPointConstraints? timingPointConstraints;
  final bool active;

  final Alignment _defaultRowAlignment = Alignment.bottomCenter;

  @override
  DASTableRow build(BuildContext context) {
    return DASTableRow(
      height: height,
      color: active ? SBBColors.royal.withOpacity(0.2) : null,
      cells: [
        _kilometre(),
        _time(),
        _route(),
        _iconsPlaceholder(),
        _journeyInformation(),
        _iconsPlaceholder(),
        _iconsPlaceholder(),
        _og(),
        _r150(),
        _advisedSpeed(),
        _actions(),
      ],
    );
  }

  DASTableCell _kilometre() {
    return DASTableCell(child: Text('10.2'), alignment: _defaultRowAlignment);
  }

  DASTableCell _time() {
    return DASTableCell(child: Text('06:05:52'), alignment: _defaultRowAlignment);
  }

  DASTableCell _route() {
    return DASTableCell(
      padding: EdgeInsets.all(0.0),
      alignment: null,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (active)
            Positioned(
              bottom: sbbDefaultSpacing,
              child: Container(
                width: 14.0,
                height: 14.0,
                decoration: BoxDecoration(
                  color: SBBColors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Positioned(
            top: -sbbDefaultSpacing,
            bottom: -sbbDefaultSpacing,
            right: 0,
            left: 0,
            child: VerticalDivider(thickness: 2.0, color: SBBColors.black),
          ),
        ],
      ),
    );
  }

  // TODO: clarify use of different icon columns
  DASTableCell _iconsPlaceholder() {
    return DASTableCell.empty();
  }

  DASTableCell _journeyInformation() {
    final servicePointName = timingPoint?.names.first.name ?? 'Unknown';
    return DASTableCell(
      alignment: _defaultRowAlignment,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(servicePointName, style: SBBTextStyles.largeBold.copyWith(fontSize: 24.0))),
          if (true) Text('B12'),
        ],
      ),
    );
  }

  // TODO: clarify name
  DASTableCell _og() {
    return DASTableCell(child: Text('85'), alignment: _defaultRowAlignment);
  }

  DASTableCell _advisedSpeed() {
    return DASTableCell(child: Text('100'), alignment: _defaultRowAlignment);
  }

  // TODO: clarify name
  DASTableCell _r150() {
    return DASTableCell(child: Text('95'), alignment: _defaultRowAlignment);
  }

  DASTableCell _actions() {
    return DASTableCell.empty();
  }
}
