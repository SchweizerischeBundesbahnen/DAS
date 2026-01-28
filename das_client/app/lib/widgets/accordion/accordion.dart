import 'package:app/util/screen_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

typedef AccordionToggleCallback = void Function();

/// The Accordion - heavily inspired be the material expansion panel list.
/// Use according to documentation.
///
/// See also:
///
/// * [ExpansionPanelList], which this widget is based on.
class Accordion extends StatelessWidget {
  static const Key collapsedKey = Key('accordionCollapsed');
  static const Key expandedKey = Key('accordionExpanded');
  static const double defaultCollapsedHeight = _headerFontSize + 2 * _collapsedVerticalPadding;
  static const double defaultExpandedHeight = _headerFontSize + 2 * _expandedVerticalPadding + _headerContentSpacing;

  /// Returns width of accordion content in logical pixels (dp).
  static double contentWidth({double? outsidePadding}) =>
      ScreenDimensions.width - 2 * Accordion._horizontalPadding - 2 * Accordion._contentPadding - (outsidePadding ?? 0);

  static const double _contentPadding = 28.0; // 24.0 (icon) + spacing
  static const double _horizontalPadding = SBBSpacing.xSmall;
  static const double _headerFontSize = 24.0; // Large Bold
  static const double _expandedVerticalPadding = SBBSpacing.medium;
  static const double _collapsedVerticalPadding = 2.0;
  static const double _headerContentSpacing = SBBSpacing.xSmall;

  const Accordion({
    required this.title,
    required this.body,
    required this.isExpanded,
    required this.toggleCallback,
    super.key,
    this.backgroundColor,
    this.icon,
    this.margin,
  });

  final String title;
  final Widget body;
  final bool isExpanded;
  final AccordionToggleCallback toggleCallback;
  final Color? backgroundColor;
  final IconData? icon;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: isExpanded ? expandedKey : collapsedKey,
      padding: margin ?? .zero,
      child: _accordion(context),
    );
  }

  Widget _accordion(BuildContext context) {
    final style = SBBControlStyles.of(context);
    return InkWell(
      onTap: () => toggleCallback(),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? style.accordionBackgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(isExpanded ? SBBSpacing.medium : SBBSpacing.xSmall),
          ),
        ),
        padding: .symmetric(
          vertical: isExpanded ? _expandedVerticalPadding : _collapsedVerticalPadding,
          horizontal: _horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _header(),
            isExpanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _contentPadding,
                    ).copyWith(top: _headerContentSpacing),
                    child: body,
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      spacing: SBBSpacing.xSmall,
      children: [
        if (icon != null) Icon(icon, size: 20.0),
        Expanded(
          child: Text(
            title,
            style: sbbTextStyle.boldStyle.large,
            maxLines: 1,
            overflow: .ellipsis,
          ),
        ),
        Icon(
          isExpanded ? SBBIcons.chevron_small_down_small : SBBIcons.chevron_small_right_small,
        ),
      ],
    );
  }
}
