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
  const Accordion({
    required this.title,
    required this.body,
    required this.isExpanded,
    required this.toggleCallback,
    super.key,
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.margin,
  });

  final String title;
  final Widget body;
  final bool isExpanded;
  final AccordionToggleCallback toggleCallback;
  final Color? backgroundColor;
  final Color? borderColor;
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
          border: Border.all(color: widget.borderColor ?? SBBColors.transparent),
          borderRadius: BorderRadius.all(
            Radius.circular(widget.isExpanded ? sbbDefaultSpacing : sbbDefaultSpacing * 0.5),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: widget.isExpanded ? sbbDefaultSpacing : 2.0,
          horizontal: sbbDefaultSpacing * 0.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            widget.isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: sbbDefaultSpacing * 0.5),
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
