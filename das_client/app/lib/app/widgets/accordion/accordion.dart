import 'package:app/app/widgets/das_text_styles.dart';
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
    required this.accordionToggleCallback,
    super.key,
    this.backgroundColor,
    this.borderColor,
    this.icon,
  });

  final String title;
  final Widget body;
  final bool isExpanded;
  final AccordionToggleCallback accordionToggleCallback;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;

  @override
  State<StatefulWidget> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  @override
  Widget build(BuildContext context) {
    final style = SBBControlStyles.of(context);

    return Material(
      color: widget.backgroundColor ?? style.accordionBackgroundColor,
      child: _buildAccordion(context),
    );
  }

  Widget _buildAccordion(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: widget.borderColor ?? SBBColors.transparent)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _accordionHeader(),
          _accordionBody(),
        ],
      ),
    );
  }

  MergeSemantics _accordionHeader() {
    return MergeSemantics(
      child: InkWell(
        onTap: () => widget.accordionToggleCallback(),
        child: Row(
          children: <Widget>[
            const SizedBox(width: sbbDefaultSpacing * 0.5),
            if (widget.icon != null)
              Padding(
                padding: const EdgeInsets.only(right: sbbDefaultSpacing * 0.5),
                child: Icon(widget.icon),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing * 0.25),
                child: Text(
                  widget.title,
                  style: DASTextStyles.smallBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                end: sbbDefaultSpacing / 2,
              ),
              child: _ExpandIcon(
                widget.isExpanded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedCrossFade _accordionBody() {
    return AnimatedCrossFade(
      firstChild: Container(height: 0.0),
      secondChild: SizedBox(
        width: double.infinity,
        child: widget.body,
      ),
      firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.fastOutSlowIn,
      crossFadeState: widget.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: kThemeAnimationDuration,
    );
  }
}

class _ExpandIcon extends StatefulWidget {
  const _ExpandIcon(this.isExpanded);

  final bool isExpanded;

  @override
  _ExpandIconState createState() => _ExpandIconState();
}

class _ExpandIconState extends State<_ExpandIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
    );
    _iconTurns = _controller.drive(
      Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).chain(
        CurveTween(
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );
    // If the widget is initially expanded, rotate the icon without animating it.
    if (widget.isExpanded) {
      _controller.value = _controller.upperBound;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RotationTransition(
        turns: _iconTurns,
        child: Icon(
          SBBIcons.chevron_small_down_small,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(_ExpandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
