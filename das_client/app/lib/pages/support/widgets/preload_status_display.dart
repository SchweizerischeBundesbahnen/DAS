import 'dart:math';

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/support/view_model/preload_view_model.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:preload/component.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class PreloadStatusDisplay extends StatelessWidget {
  static const downloadedSegmentKey = ValueKey('PreloadStatusDisplayDownloadSegmentKey');
  static const initialSegmentKey = ValueKey('PreloadStatusDisplayInitialSegmentKey');

  const PreloadStatusDisplay({super.key});

  static final _progressBarHeight = 20.0;
  static final downloadedColor = SBBColors.night;
  static final initialColor = SBBColors.sky;
  static final errorColor = SBBColors.violet;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<PreloadViewModel>();

    return StreamBuilder(
      stream: vm.preloadDetails,
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          spacing: SBBSpacing.xSmall,
          children: [
            SBBListHeader(
              context.l10n.w_preload_status_title,
              style: SBBListHeaderStyle(padding: .only(left: SBBSpacing.medium)),
            ),
            SBBContentBox(
              padding: EdgeInsets.all(SBBSpacing.medium),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisSize: .min,
                spacing: SBBSpacing.xSmall,
                children: [
                  _progressBarRow(snapshot.data),
                  _description(context, snapshot.data),
                ],
              ),
            ),
            SBBTertiaryButtonSmall(
              onPressed: () {
                showSBBPopup(
                  style: SBBPopupStyle(
                    constraints: BoxConstraints(maxWidth: 430.0),
                    padding: EdgeInsets.all(SBBSpacing.medium).copyWith(bottom: SBBSpacing.xLarge),
                  ),
                  context: context,
                  titleText: 'Information zum Vorladen',
                  body: Text("""Mit dem Vorladen werden Fahrordnungen, welche aktuell oder in den nächsten Stunden abfahren, auf den DAS Client vorgeladen, damit sie auch offline genutzt werden können. 

Diese Info braucht der Support, falls Fehler auftauchen."""),
                );
              },
              labelText: 'Information zum Vorladen',
              iconData: SBBIcons.circle_information_small,
            ),
          ],
        );
      },
    );
  }

  Widget _progressBarRow(PreloadDetails? preloadDetails) {
    Widget? child;
    if (preloadDetails != null) {
      final minWidth = (preloadDetails.totalFilesCount * 0.025).ceil();
      child = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (preloadDetails.downloadedFilesCount > 0)
            _progressSegment(
              preloadDetails.downloadedFilesCount,
              downloadedColor,
              minWidth: minWidth,
              key: PreloadStatusDisplay.downloadedSegmentKey,
            ),
          if (preloadDetails.initialFilesCount > 0)
            _progressSegment(
              preloadDetails.initialFilesCount,
              initialColor,
              minWidth: minWidth,
              key: PreloadStatusDisplay.initialSegmentKey,
            ),
          if (preloadDetails.errorFilesCount > 0)
            _progressSegment(preloadDetails.errorFilesCount, errorColor, minWidth: minWidth),
        ],
      );
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: SBBColors.metal,
      ),
      height: _progressBarHeight,
      width: double.maxFinite,
      child: child,
    );
  }

  Widget _progressSegment(int count, Color color, {required int minWidth, Key? key}) {
    return Expanded(
      key: key,
      flex: max(minWidth, count),
      child: Container(
        color: color,
        child: Align(
          alignment: .center,
          child: Text(count.toString(), style: SBBTextStyles.smallLight.copyWith(color: SBBColors.white)),
        ),
      ),
    );
  }

  Widget _description(BuildContext context, PreloadDetails? preloadDetails) {
    return Row(
      spacing: SBBSpacing.large,
      crossAxisAlignment: .start,
      children: [
        Expanded(flex: 1, child: _legend(context)),
        Expanded(flex: 1, child: _metrics(context, preloadDetails)),
        Expanded(flex: 1, child: _status(context, preloadDetails)),
        Expanded(flex: 1, child: _startButton(context, preloadDetails)),
      ],
    );
  }

  Widget _legend(BuildContext context) {
    return Column(
      children: [
        _legendItem(downloadedColor, context.l10n.w_preload_status_downloaded),
        _legendItem(initialColor, context.l10n.w_preload_status_initial),
        _legendItem(errorColor, context.l10n.w_preload_status_error),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color),
        SizedBox(width: SBBSpacing.xSmall),
        Text(label, style: SBBTextStyles.smallLight),
      ],
    );
  }

  Widget _metrics(BuildContext context, PreloadDetails? preloadDetails) {
    return Column(
      children: [
        _labelValueItem(context.l10n.w_preload_status_metric_jp, preloadDetails?.metrics.jpCount.toString()),
        _labelValueItem(context.l10n.w_preload_status_metric_sp, preloadDetails?.metrics.spCount.toString()),
        _labelValueItem(context.l10n.w_preload_status_metric_tc, preloadDetails?.metrics.tcCount.toString()),
      ],
    );
  }

  Widget _labelValueItem(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: SBBTextStyles.smallLight),
        Text(value ?? '-', style: SBBTextStyles.smallLight),
      ],
    );
  }

  Widget _status(BuildContext context, PreloadDetails? preloadDetails) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        _labelValueItem(
          context.l10n.w_preload_status_state_text,
          preloadDetails?.status.localizedText(context) ?? '-',
        ),
        _labelValueItem(context.l10n.w_preload_status_last_update, Format.datetime(preloadDetails?.lastUpdated, '-')),
      ],
    );
  }

  Widget _startButton(BuildContext context, PreloadDetails? preloadDetails) {
    return SBBTertiaryButtonSmall(
      labelText: context.l10n.w_preload_status_start_preload,
      onPressed: preloadDetails?.status == PreloadStatus.idle
          ? () => context.read<PreloadViewModel>().triggerPreload()
          : null,
    );
  }
}

extension PreloadStatusX on PreloadStatus {
  String localizedText(BuildContext context) => switch (this) {
    .idle => context.l10n.w_preload_status_idle,
    .running => context.l10n.w_preload_status_running,
    .missingConfiguration => context.l10n.w_preload_status_missing_configuration,
  };
}
