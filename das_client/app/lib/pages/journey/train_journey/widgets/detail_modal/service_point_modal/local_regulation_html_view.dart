import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocalRegulationHtmlView extends StatefulWidget {
  static const webViewKey = Key('localRegulationWebView');

  const LocalRegulationHtmlView({required this.html, super.key});

  final String html;

  @override
  State<LocalRegulationHtmlView> createState() => _LocalRegulationHtmlViewState();
}

class _LocalRegulationHtmlViewState extends State<LocalRegulationHtmlView> {
  late WebViewController _controller;
  bool _isPageLoaded = false;

  @override
  void initState() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isPageLoaded = true);
          },
        ),
      )
      ..loadHtmlString(widget.html);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPageLoaded) return Center(child: CircularProgressIndicator());

    return WebViewWidget(
      key: LocalRegulationHtmlView.webViewKey,
      controller: _controller,
    );
  }
}
