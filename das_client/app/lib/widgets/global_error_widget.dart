import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Widget that is provided by [ErrorWidget.builder] and displayed when an unexpected error happened during build time.
class GlobalErrorWidget extends StatelessWidget {
  const GlobalErrorWidget({
    required this.details,
    super.key,
  });

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: SBBTheme.light(themeContext: .safety),
      localizationsDelegates: localizationDelegates,
      supportedLocales: supportedLocales,
      localeResolutionCallback: defaultLocale,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: SBBHeaderSmall(titleText: context.l10n.c_app_name),
            body: SafeArea(
              child: Center(
                child: _errorMessage(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorMessage(BuildContext context) {
    return SBBMessage(
      titleText: context.l10n.w_global_error_widget_title,
      subtitleText: context.l10n.w_global_error_widget_description,
      errorText: details.exceptionAsString(),
      action: SBBTertiaryButton(
        iconData: SBBIcons.speech_bubble_exclamation_point_small,
        onPressed: () => _showErrorDetailsModalSheet(context, details),
      ),
    );
  }
}

Future<void> _showErrorDetailsModalSheet(BuildContext context, FlutterErrorDetails details) async {
  final errorDetails = details.toString(minLevel: .debug);
  return showSBBBottomSheet(
    context: context,
    titleText: details.exceptionAsString(),
    isScrollControlled: true,
    style: SBBBottomSheetStyle(
      constraints: BoxConstraints(), // TODO: Check if scrollControlDisabledMaxHeightRatio: 1 needed,
    ),
    body: SingleChildScrollView(
      child: Container(
        padding: .all(SBBSpacing.medium),
        width: double.maxFinite,
        child: Text(errorDetails, style: sbbTextStyle.lightStyle.small),
      ),
    ),
  );
}
