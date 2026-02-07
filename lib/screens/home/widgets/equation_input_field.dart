import "package:flutter/material.dart";
import "package:nxcalculator/utils/ui.dart";

class EquationInputField extends StatelessWidget {
  const EquationInputField({
    required this.shrink,
    required this.equation,
    required this.onSelectionChanged,
    this.style,
    super.key,
  });

  final bool shrink;
  final TextStyle? style;
  final List<String> equation;
  final Function(int cursorPosition)? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: SelectableText.rich(
        maxLines: 1,
        autofocus: true,
        showCursor: true,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        textAlign: TextAlign.end,
        strutStyle: StrutStyle(
          forceStrutHeight: true,
          fontSize: style?.fontSize,
        ),
        onSelectionChanged: (selection, cause) {
          if (selection.start == selection.end) {
            onSelectionChanged?.call(selection.start);
          }
        },
        TextSpan(
          style: style,
          children: equation.map((text) {
            return getEquationText(
              text,
              superFontSize: 32,
              superVerticalOffset: -16,
            );
          }).toList(),
        ),
      ),
    );
  }
}
