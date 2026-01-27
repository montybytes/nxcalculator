import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

InlineSpan getEquationText(
  String text, {
  required double fontSize,
  required double verticalOffset,
}) {
  if (text == "^2") {
    return WidgetSpan(
      alignment: PlaceholderAlignment.top,
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Text(
          text.replaceAll("^", ""),
          textScaler: const TextScaler.linear(0.7),
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
  return TextSpan(text: text);
}

RoundedRectangleBorder buildListTileBorder(int index, int listLength) {
  if (listLength == 0) {
    return defaultBorderRadius;
  }
  if (listLength == 1) {
    return largeBorderRadius;
  } else if (index == 0) {
    return startBorderRadius;
  } else if (index == listLength - 1) {
    return endBorderRadius;
  }

  return defaultBorderRadius;
}
