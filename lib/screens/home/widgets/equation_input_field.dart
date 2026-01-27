import "package:flutter/material.dart";
import "package:nxcalculator/utils/ui.dart";

class EquationInputField extends StatelessWidget {
  const EquationInputField({
    required this.shrink,
    required this.equation,
    required this.onSelectionChanged,
    super.key,
  });

  final bool shrink;
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
          fontSize: shrink ? 52 : 64,
        ),
        onSelectionChanged: (selection, cause) {
          if (selection.start == selection.end) {
            onSelectionChanged?.call(selection.start);
          }
        },
        TextSpan(
          style: TextStyle(
            letterSpacing: -8,
            fontFamily: "LetteraMono",
            fontSize: shrink ? 52 : 64,
          ),
          children: equation.map((text) {
            return getEquationText(text, fontSize: 32, verticalOffset: -16);
          }).toList(),
        ),
      ),
    );
  }
}
