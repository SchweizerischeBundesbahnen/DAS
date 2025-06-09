import 'package:app/nav/das_navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const _toolbarAnimationDuration = Duration(milliseconds: 400);

class DASJourneyScaffold extends StatefulWidget {
  const DASJourneyScaffold({
    required this.body,
    required this.appBarTitle,
    this.appBarTrailingAction,
    this.showAppBar = true,
    super.key,
  });

  final Widget body;
  final String appBarTitle;
  final Widget? appBarTrailingAction;
  final bool showAppBar;

  @override
  State<DASJourneyScaffold> createState() => _DASJourneyScaffoldState();
}

class _DASJourneyScaffoldState extends State<DASJourneyScaffold> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  double _toolbarHeight = kToolbarHeight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _toolbarAnimationDuration);
    _animation = Tween<double>(begin: kToolbarHeight, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _toolbarHeight = _animation.value;
        });
      });
  }

  @override
  void didUpdateWidget(covariant DASJourneyScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAppBar != oldWidget.showAppBar) {
      widget.showAppBar ? _controller.reverse() : _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      //Handling overflow issues in train selection when tablet is too small
      resizeToAvoidBottomInset: screenHeight <= 830 ? true : null,
      appBar: _appBar(context),
      body: widget.body,
      drawer: const DASNavigationDrawer(),
    );
  }

  PreferredSizeWidget? _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(_toolbarHeight),
      child: SBBHeader(
        title: widget.appBarTitle,
        actions: widget.appBarTrailingAction != null ? [widget.appBarTrailingAction!] : null,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
