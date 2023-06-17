import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
class WebViewPage extends StatelessWidget {
  final String htmlContent;
  final TextStyle textStyle;

  WebViewPage({required this.htmlContent,required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: HtmlWidget(htmlContent,textStyle:textStyle,buildAsync: true,),
    );
  }
}
