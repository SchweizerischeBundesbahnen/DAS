import 'package:app/util/screen_dimensions.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

typedef AccordionToggleCallback = void Function();

/// The Accordion - heavily inspired be the material expansion panel list.
/// Use according to documentation.
///
/// See also:
///
/// * [ExpansionPanelList], which this widget is based on.
class Accordion extends StatefulWidget {
  static const double defaultCollapsedHeight = _headerFontSize + 2 * _collapsedVerticalPadding;
  static const double defaultExpandedHeight = _headerFontSize + 2 * _expandedVerticalPadding + _headerContentSpacing;

  /// Returns width of accordion content in logical pixels (dp).
  static double contentWidth({double? outsidePadding}) =>
      ScreenDimensions.width - 2 * Accordion._horizontalPadding - 2 * Accordion._contentPadding - (outsidePadding ?? 0);

  static const double _contentPadding = 28.0; // 24.0 (icon) + spacing
  static const double _horizontalPadding = sbbDefaultSpacing * 0.5;
  static const double _headerFontSize = 24.0; // Large Bold
  static const double _expandedVerticalPadding = sbbDefaultSpacing;
  static const double _collapsedVerticalPadding = 2.0;
  static const double _headerContentSpacing = sbbDefaultSpacing * 0.5;

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
  State<StatefulWidget> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: _accordion(context),
    );
  }

  Widget _accordion(BuildContext context) {
    final style = SBBControlStyles.of(context);
    return InkWell(
      onTap: () => widget.toggleCallback(),
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? style.accordionBackgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(widget.isExpanded ? sbbDefaultSpacing : sbbDefaultSpacing * 0.5),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: widget.isExpanded ? Accordion._expandedVerticalPadding : Accordion._collapsedVerticalPadding,
          horizontal: Accordion._horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            widget.isExpanded
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Accordion._contentPadding,
                    ).copyWith(top: Accordion._headerContentSpacing),
                    child: widget.body,
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      spacing: sbbDefaultSpacing * 0.5,
      children: [
        if (widget.icon != null) Icon(widget.icon, size: 20.0),
        Expanded(
          child: Text(
            widget.title,
            style: DASTextStyles.largeBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          widget.isExpanded ? SBBIcons.chevron_small_down_small : SBBIcons.chevron_small_right_small,
        ),
      ],
    );
  }
}
