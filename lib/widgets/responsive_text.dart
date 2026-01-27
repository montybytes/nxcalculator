import "package:flutter/material.dart";

class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    this.maxFontSize = 24,
    this.minFontSize = 12,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String text;
  final double maxFontSize;
  final double minFontSize;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = maxFontSize;

        while (fontSize > minFontSize) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: style?.copyWith(fontSize: fontSize),
            ),
            maxLines: maxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          if (!painter.didExceedMaxLines) {
            break;
          }
          fontSize -= 1;
        }

        return Text(
          text,
          maxLines: maxLines,
          overflow: overflow,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
        );
      },
    );
  }
}
