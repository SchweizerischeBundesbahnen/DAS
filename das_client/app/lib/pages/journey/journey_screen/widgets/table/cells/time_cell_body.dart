import 'package:app/extension/arrival_departure_time_extension.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_cell_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TimeCellBody extends StatelessWidget {
  static const timeCellKey = Key('timeCellKey');

  const TimeCellBody({
    required this.viewModel,
    required this.showTimesInBrackets,
    required this.mandatoryStop,
    this.times,
    super.key,
  });

  final ArrivalDepartureTime? times;
  final ArrivalDepartureTimeViewModel viewModel;
  final bool showTimesInBrackets;
  final bool mandatoryStop;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.combine2<bool, DateTime, (bool, DateTime)>(
        viewModel.showOperationalTime,
        viewModel.wallclockTimeToMinute,
        (a, b) => (a, b),
      ),
      initialData: (viewModel.showOperationalTimeValue, viewModel.wallclockTimeToMinuteValue),
      builder: (context, snapshot) {
        final showOperationalTime = snapshot.requireData.$1;
        final currentTime = snapshot.requireData.$2;

        final formattedTimes = times.formattedTimes(
          showOperationalTime: showOperationalTime,
          showTimesInBrackets: showTimesInBrackets,
          currentTime: currentTime,
        );
        final departureTime = formattedTimes.departureTime;
        final arrivalTime = formattedTimes.arrivalTime;

        if (departureTime.isEmpty && arrivalTime.isEmpty && mandatoryStop) {
          return SizedBox.shrink(key: DASTableCell.emptyCellKey);
        }

        final isArrivalBold = departureTime.isEmpty && !showOperationalTime;
        final departureStyle = formattedTimes.isDepartureBold
            ? sbbTextStyle.boldStyle.large
            : sbbTextStyle.romanStyle.large;

        final timeTexts = Text.rich(
          key: timeCellKey,
          TextSpan(
            children: [
              TextSpan(
                text: arrivalTime,
                style: isArrivalBold ? sbbTextStyle.boldStyle.large : sbbTextStyle.romanStyle.large,
              ),
              TextSpan(
                text: departureTime,
                style: departureStyle.copyWith(
                  decoration: formattedTimes.isDepartureUnderlined ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: DASTableCellStyle.of(context)?.foregroundColor,
                ),
              ),
            ],
          ),
        );

        if (!mandatoryStop && departureTime.isEmpty && arrivalTime.isEmpty) {
          return Align(alignment: .centerRight, child: _stopOnRequestIcon(context));
        }

        return Row(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          spacing: SBBSpacing.xxSmall,
          children: [
            timeTexts,
            Align(alignment: .topRight, child: _additionalIcon(context)),
          ],
        );
      },
    );
  }

  Widget _additionalIcon(BuildContext context) {
    final fixedPointRelevance = times?.fixedPointRelevance == true;

    if (!mandatoryStop && fixedPointRelevance) {
      return Column(
        mainAxisSize: .min,
        children: [
          _fixedPointRelevanceStopOnRequestIcon(context),
          _stopOnRequestIcon(context),
        ],
      );
    } else if (!mandatoryStop) {
      return _stopOnRequestIcon(context);
    } else if (fixedPointRelevance) {
      return _fixedPointRelevanceIcon(context);
    }

    return SizedBox.shrink();
  }

  Widget _fixedPointRelevanceStopOnRequestIcon(BuildContext context) =>
      _fixedPointRelevanceBase(context, AppAssets.iconFixedPointRelevanceStopOnRequest);

  Widget _fixedPointRelevanceIcon(BuildContext context) =>
      _fixedPointRelevanceBase(context, AppAssets.iconFixedPointRelevance);

  Widget _fixedPointRelevanceBase(BuildContext context, String icon) {
    return Padding(
      padding: const EdgeInsets.only(top: SBBSpacing.xxSmall),
      child: SvgPicture.asset(
        icon,
        key: ServicePointRow.fixedPointRelevanceKey,
        colorFilter: ColorFilter.mode(
          DASTableCellStyle.of(context)?.secondaryForegroundColor ?? ThemeUtil.getIconSecondaryColor(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _stopOnRequestIcon(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconStopOnRequest,
      key: ServicePointRow.stopOnRequestKey,
      colorFilter: ColorFilter.mode(
        DASTableCellStyle.of(context)?.foregroundColor ?? ThemeUtil.getIconColor(context),
        BlendMode.srcIn,
      ),
    );
  }
}
