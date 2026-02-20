import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/replacement_series_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/replacement_series_view_model.dart';
import 'package:app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplacementSeriesNotification extends StatelessWidget {
  static const Key replacementSeriesAvailableKey = Key('replacementSeriesAvailable');
  static const Key originalSeriesAvailableKey = Key('originalSeriesAvailable');
  static const Key noReplacementSeriesAvailableKey = Key('noReplacementSeriesAvailable');

  const ReplacementSeriesNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ReplacementSeriesViewModel>();

    return StreamBuilder<ReplacementSeriesModel?>(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        return switch (snapshot.data) {
          ReplacementSeriesAvailable() => _replacementSeriesAvailableNotification(
            context,
            snapshot.data as ReplacementSeriesAvailable,
          ),
          OriginalSeriesAvailable() => _replacementSeriesOriginalNotification(
            context,
            snapshot.data as OriginalSeriesAvailable,
          ),
          NoReplacementSeries() => _noReplacementSeriesAvailableNotification(
            context,
            snapshot.data as NoReplacementSeries,
          ),
          ReplacementSeriesSelected() => SizedBox.shrink(),
          null => SizedBox.shrink(),
        };
      },
    );
  }

  Widget _noReplacementSeriesAvailableNotification(BuildContext context, NoReplacementSeries model) {
    return _notification(
      key: noReplacementSeriesAvailableKey,
      style: .information,
      title: context.l10n.w_replacement_series_notification_none_title(
        model.segment.start.name,
      ),
      text: context.l10n.w_replacement_series_notification_none_text,
    );
  }

  Widget _replacementSeriesAvailableNotification(BuildContext context, ReplacementSeriesAvailable model) {
    return _notification(
      key: replacementSeriesAvailableKey,
      style: .warning,
      title: context.l10n.w_replacement_series_notification_available_title(
        model.segment.start.name,
        model.segment.end.name,
      ),
      text: context.l10n.w_replacement_series_notification_available_text(
        model.segment.replacement?.name ?? '',
      ),
    );
  }

  Widget _replacementSeriesOriginalNotification(BuildContext context, OriginalSeriesAvailable model) {
    return _notification(
      key: originalSeriesAvailableKey,
      style: .warning,
      title: context.l10n.w_replacement_series_notification_original_title(
        model.segment.end.name,
        model.segment.original.name,
      ),
    );
  }

  Widget _notification({required String title, required NotificationBoxStyle style, String? text, Key? key}) {
    return NotificationBox(
      key: key,
      style: style,
      title: title,
      text: text,
    );
  }
}
