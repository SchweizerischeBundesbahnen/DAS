import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_html_table/flutter_html_table.dart';

class LocalRegulationHtmlView extends StatelessWidget {
  const LocalRegulationHtmlView({required this.html, super.key});

  final String html;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: html,
      style: _style(context),
      extensions: [
        TableHtmlExtension(),
        SvgHtmlExtension(),
      ],
    );
  }

  Map<String, Style> _style(BuildContext context) {
    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.symmetric(horizontal: 0),
      ),
      'img': Style(
        width: Width(
          MediaQuery.of(context).size.width,
          Unit.auto,
        ),
      ),
      'img, svg': Style(
        verticalAlign: VerticalAlign.middle,
      ),
      'table': Style(
        width: Width(
          MediaQuery.of(context).size.width,
          Unit.auto,
        ),
        verticalAlign: VerticalAlign.top,
        margin: Margins(bottom: Margin(1, Unit.rem)),
        border: Border.all(color: Color(0xFFd2d2d2)),
      ),
      'th': Style(
        backgroundColor: Color(0xFFe5e5e5),
        height: Height(4.0, Unit.rem),
        border: Border.all(color: Color(0xFFd2d2d2)),
      ),
      'td, tr': Style(height: Height(2.25, Unit.rem)),
      'th, tr, td': Style(padding: HtmlPaddings()),
    };
  }
}
