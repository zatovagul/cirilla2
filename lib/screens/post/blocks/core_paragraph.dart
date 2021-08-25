import 'package:cirilla/mixins/utility_mixin.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:url_launcher/url_launcher.dart';

Map<String, Style> styleBlog({String align, bool pad, double fontSize}) {
  return {
    'html': Style(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
    ),
    'body': Style(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
    ),
    'p': Style(
        lineHeight: LineHeight(1.8),
        fontSize: FontSize(fontSize),
        padding: EdgeInsets.only(right: pad == true ? 40 : 0),
        textAlign: align == 'left'
            ? TextAlign.left
            : align == 'right'
                ? TextAlign.right
                : align == "justify"
                    ? TextAlign.justify
                    : TextAlign.center),
    'div': Style(
      lineHeight: LineHeight(1.8),
      fontSize: FontSize(15),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
    ),
    'img': Style(
      padding: EdgeInsets.symmetric(vertical: 8),
    )
  };
}

class Paragraph extends StatelessWidget with Utility {
  final Map<String, dynamic> block;

  final String alignCover;

  final bool padCover;

  const Paragraph({Key key, this.block, this.alignCover, this.padCover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map attrs =
        get(block, ['attrs'], {}) is Map ? get(block, ['attrs'], {}) : {};

    String alignCover = attrs['align'] ?? "justify";

    Map style =
        get(attrs, ['style'], {}) is Map ? get(attrs, ['style'], {}) : {};

    int fontSize = get(style, ['typography', 'fontSize'], 15);
    final data = block['innerHTML'];
    print(data.contains("\n"));
    if (data.length <= 2 && data.contains("\n")) {
      return SizedBox();
    }
    return Html(
      data: "<div>${block['innerHTML']}</div>",
      style: styleBlog(
          align: alignCover, pad: padCover, fontSize: fontSize.toDouble()),
      onLinkTap: (link, context, v, v1) {
        final url = Uri.encodeFull(link);
        launch(url);
      },
    );
    // return Html(
    //   data: "<div>${block['innerHTML']}</div>",
    //   style: styleBlog(
    //       align: alignCover, pad: padCover, fontSize: fontSize.toDouble()),
    //   onLinkTap: (link, context, v, v1) {
    //     final url = Uri.encodeFull(link);
    //     launch(url);
    //   },
    // );
  }
}
