import 'package:app/pages/journey/journey_screen/header/view_model/departure_authorization_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DepartureAuthorizationDisplay extends StatelessWidget {
  static const departureAuthorizationIconKey = Key('departureAuthorizationDisplayIcon');
  static const departureAuthorizationTextKey = Key('departureAuthorizationDisplayText');

  const DepartureAuthorizationDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: SBBSpacing.xSmall,
      children: [
        Icon(
          key: departureAuthorizationIconKey,
          SBBIcons.hand_clock_small,
          color: ThemeUtil.getIconColor(context),
        ),
        _departureAuthorization(context),
      ],
    );
  }

  Widget _departureAuthorization(BuildContext context) {
    final viewModel = context.read<DepartureAuthorizationViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final departureAuthText = snapshot.data?.departureAuthText;
        if (departureAuthText == null) return SizedBox.shrink();

        final parsed = TextUtil.parseHtmlText(departureAuthText, sbbTextStyle.romanStyle.large);
        return Text.rich(
          key: departureAuthorizationTextKey,
          _replaceAsteriskWithStyle(parsed, sbbTextStyle.boldStyle.xxLarge),
        );
      },
    );
  }
}

/// Recursively replaces every '*' character with a TextSpan that uses [style].
InlineSpan _replaceAsteriskWithStyle(InlineSpan span, TextStyle style) {
  if (span is! TextSpan) return span;

  final transformedChildren = span.children?.map((c) => _replaceAsteriskWithStyle(c, style)).toList();

  final text = span.text;
  final hasStar = text != null && text.contains('*');
  if (!hasStar) {
    if (transformedChildren == null) return span;
    return TextSpan(text: text, style: span.style, children: transformedChildren);
  }

  final parts = text.split('*');
  final pieces = <InlineSpan>[];
  for (int i = 0; i < parts.length; i++) {
    final part = parts[i];
    if (part.isNotEmpty) {
      pieces.add(TextSpan(text: part, style: span.style));
    }
    if (i < parts.length - 1) {
      pieces.add(TextSpan(text: '*', style: style));
    }
  }

  if (transformedChildren != null && transformedChildren.isNotEmpty) {
    pieces.addAll(transformedChildren);
  }

  return TextSpan(style: span.style, children: pieces);
}
