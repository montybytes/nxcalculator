import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";



InlineSpan getEquationText(
  String text, {
  required double superVerticalOffset,
  TextStyle? superStyle,
}) {
  if (text == "^2") {
    return WidgetSpan(
      alignment: PlaceholderAlignment.top,
      child: Transform.translate(
        offset: Offset(0, superVerticalOffset),
        child: Text(
          text.replaceAll("^", ""),
          textScaler: const TextScaler.linear(0.7),
          style: superStyle,
        ),
      ),
    );
  }
  return TextSpan(text: text);
}

WidgetSpan superscript(String text) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.top,
    child: Transform.translate(
      offset: const Offset(0, -6),
      child: Text(
        text,
        textScaler: const TextScaler.linear(0.7),
        style: const TextStyle(fontSize: 20),
      ),
    ),
  );
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
