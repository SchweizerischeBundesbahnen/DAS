import 'package:app/i18n/i18n.dart';
import 'package:app/theme/themes.dart';
import 'package:app/widgets/das_text_styles.dart';
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
      theme: DASTheme.light(),
      localizationsDelegates: localizationDelegates,
      supportedLocales: supportedLocales,
      localeResolutionCallback: defaultLocale,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: SBBHeader(title: context.l10n.c_app_name),
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
    return SBBMessage.error(
      title: context.l10n.w_global_error_widget_title,
      description: context.l10n.w_global_error_widget_description,
      messageCode: details.exceptionAsString(),
      interactionIcon: SBBIcons.speech_bubble_exclamation_point_small,
      onInteraction: () => _showErrorDetailsModalSheet(context, details),
    );
  }
}

Future<void> _showErrorDetailsModalSheet(BuildContext context, FlutterErrorDetails details) async {
  final errorDetails = details.toString(minLevel: DiagnosticLevel.debug);
  return showSBBModalSheet(
    context: context,
    title: details.exceptionAsString(),
    constraints: BoxConstraints(),
    child: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(sbbDefaultSpacing),
        width: double.maxFinite,
        child: Text(errorDetails, style: DASTextStyles.smallLight),
      ),
    ),
  );
}
