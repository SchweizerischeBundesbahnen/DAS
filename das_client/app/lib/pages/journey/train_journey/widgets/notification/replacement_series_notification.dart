import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/replacement_series_model.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/replacement_series_view_model.dart';
import 'package:app/widgets/notificationbox/notification_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplacementSeriesNotification extends StatelessWidget {
  static const Key replacementSeriesAvailableKey = Key('replacementSeriesAvailable');
  static const Key originalSeriesAvailableKey = Key('originalSeriesAvailable');

  const ReplacementSeriesNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ReplacementSeriesViewModel>();

    return StreamBuilder<ReplacementSeriesModel?>(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        return switch (snapshot.data) {
          ReplacementSeriesAvailable() => _replacementSeriesAvailableWidget(
            context,
            snapshot.data as ReplacementSeriesAvailable,
          ),
          OriginalSeriesAvailable() => _replacementSeriesOriginalWidget(
            context,
            snapshot.data as OriginalSeriesAvailable,
          ),
          ReplacementSeriesSelected() => SizedBox.shrink(),
          null => SizedBox.shrink(),
        };
      },
    );
  }

  Widget _replacementSeriesAvailableWidget(BuildContext context, ReplacementSeriesAvailable model) {
    return _buildNotification(
      key: replacementSeriesAvailableKey,
      title: context.l10n.w_replacement_series_notification_available_title(
        model.segment.start.name,
        model.segment.end.name,
      ),
      text: context.l10n.w_replacement_series_notification_available_text(
        model.segment.replacement.toString(),
      ),
    );
  }

  Widget _replacementSeriesOriginalWidget(BuildContext context, OriginalSeriesAvailable model) {
    return _buildNotification(
      key: originalSeriesAvailableKey,
      title: context.l10n.w_replacement_series_notification_original_title(
        model.segment.end.name,
        model.segment.original.toString(),
      ),
    );
  }

  Widget _buildNotification({required String title, String? text, Key? key}) {
    return Container(
      key: key,
      margin: EdgeInsets.all(TrainJourneyOverview.horizontalPadding).copyWith(top: 0),
      child: NotificationBox(
        style: NotificationBoxStyle.warning,
        title: title,
        text: text,
      ),
    );
  }
}
