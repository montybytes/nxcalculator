import "package:flutter/material.dart";
import "package:nxcalculator/utils/ui.dart";

class EquationInputField extends StatelessWidget {
  const EquationInputField({
    required this.equation,
    super.key,
    this.style,
    this.clip = true,
    this.maxFontSize = 48,
    this.minFontSize = 12,
    this.onSelectionChanged,
    this.focusNode,
  });

  final List<String> equation;
  final Function(int cursorPosition)? onSelectionChanged;
  final FocusNode? focusNode;

  final TextStyle? style;
  final double maxFontSize;
  final double minFontSize;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(
      context,
    ).style.merge(style ?? const TextStyle());

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        if (maxWidth.isInfinite || maxWidth <= 0) {
          return _buildSelectableText(
            styleOverride: baseStyle.copyWith(fontSize: minFontSize),
            superFontSize: minFontSize - 8,
            superVerticalOffset: -minFontSize / 8,
          );
        }

        final chosenSize = _findFontSizeThatFits(
          equation.join(),
          maxWidth,
          baseStyle,
        );

        final fitsWithoutScrolling = chosenSize > minFontSize;

        if (fitsWithoutScrolling) {
          return _buildSelectableText(
            styleOverride: baseStyle.copyWith(fontSize: chosenSize),
            superFontSize: chosenSize - 8,
            superVerticalOffset: -chosenSize / 8,
          );
        }

        return SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          clipBehavior: clip == false ? Clip.none : Clip.hardEdge,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: _buildSelectableText(
              styleOverride: baseStyle.copyWith(fontSize: minFontSize),
              superFontSize: chosenSize - 8,
              superVerticalOffset: -chosenSize / 8,
            ),
          ),
        );
      },
    );
  }

  double _measureWidth(String text, TextStyle textStyle) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    tp.layout();
    return tp.width;
  }

  double _findFontSizeThatFits(
    String text,
    double maxWidth,
    TextStyle baseStyle,
  ) {
    if (_measureWidth(text, baseStyle.copyWith(fontSize: maxFontSize)) <=
        maxWidth) {
      return maxFontSize;
    }

    double low = minFontSize;
    double high = maxFontSize;
    double best = minFontSize;

    for (var i = 0; i < 20; i++) {
      final mid = (low + high) / 2;
      final width = _measureWidth(text, baseStyle.copyWith(fontSize: mid));
      if (width <= maxWidth) {
        best = mid;
        low = mid;
      } else {
        high = mid;
      }
    }

    if (best > maxFontSize) {
      best = maxFontSize;
    }
    if (best < minFontSize) {
      best = minFontSize;
    }
    return best;
  }

  SelectableText _buildSelectableText({
    required TextStyle styleOverride,
    required double superFontSize,
    required double superVerticalOffset,
  }) {
    return SelectableText.rich(
      maxLines: 1,
      showCursor: true,
      focusNode: focusNode,
      textAlign: TextAlign.end,
      style: styleOverride,
      onSelectionChanged: (selection, cause) {
        if (cause == SelectionChangedCause.drag ||
            cause == SelectionChangedCause.tap) {
          if (selection.start == selection.end) {
            onSelectionChanged?.call(selection.start);
          }
        }
      },
      TextSpan(
        style: style,
        children: equation.map((token) {
          return getEquationText(
            token,
            superFontSize: superFontSize,
            superVerticalOffset: superVerticalOffset,
          );
        }).toList(),
      ),
    );
  }
}
