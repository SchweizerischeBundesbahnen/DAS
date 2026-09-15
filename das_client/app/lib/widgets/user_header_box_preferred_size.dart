import 'dart:math';

import 'package:app/di/di.dart';
import 'package:auth/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// [SBBHeaderBoxPreferredSize] showing the currently logged in user.
class UserHeaderBoxPreferredSize extends StatelessWidget implements PreferredSizeWidget {
  UserHeaderBoxPreferredSize({required this.textScaler, super.key});

  static const _textPadding = 2.0;

  static final _sizingStyle = SBBHeaderBoxStyle.$default(
    baseStyle: SBBBaseStyle.$default(brightness: Brightness.light, themeContext: SBBThemeContext.sbb),
  );

  final TextScaler textScaler;

  late final SBBHeaderBoxPreferredSize _sizingDelegate = _headerBox();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DI.get<Authenticator>().user(),
      builder: (context, asyncSnapshot) => _headerBox(
        displayName: asyncSnapshot.data?.displayName,
        userId: asyncSnapshot.data?.userId,
      ),
    );
  }

  SBBHeaderBoxPreferredSize _headerBox({String? displayName, String? userId}) => SBBHeaderBoxPreferredSize(
    textScaler: textScaler,
    body: PreferredSize(
      preferredSize: _bodySize,
      child: SizedBox(
        height: _bodySize.height,
        child: _UserContent(displayName: displayName ?? '', userId: userId ?? ''),
      ),
    ),
  );

  Size get _bodySize {
    final textHeight =
        _lineHeight(_sizingStyle.titleTextStyle!) +
        _sizingStyle.titleSubtitleGap! +
        _lineHeight(_sizingStyle.subtitleTextStyle!);

    return Size.fromHeight(max(IconThemeData.fallback().size!, textHeight));
  }

  double _lineHeight(TextStyle style) => style.height! * textScaler.scale(style.fontSize!) + _textPadding * 2;

  @override
  Size get preferredSize => _sizingDelegate.preferredSize;
}

class _UserContent extends StatelessWidget {
  const _UserContent({required this.displayName, required this.userId});

  final String displayName;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).sbbHeaderBoxTheme.style;

    return Row(
      spacing: SBBSpacing.xSmall,
      children: [
        Icon(SBBIcons.user_medium, color: style?.leadingForegroundColor, size: 36.0),
        Expanded(
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            crossAxisAlignment: .start,
            spacing: style?.titleSubtitleGap ?? 0.0,
            children: [
              _text(displayName, style?.titleTextStyle, style?.titleForegroundColor),
              _text(userId, style?.subtitleTextStyle, style?.subtitleForegroundColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _text(String data, TextStyle? textStyle, Color? color) => Padding(
    padding: const .symmetric(vertical: UserHeaderBoxPreferredSize._textPadding),
    child: Text(
      data,
      maxLines: 1,
      overflow: .ellipsis,
      style: textStyle?.copyWith(color: color),
    ),
  );
}
