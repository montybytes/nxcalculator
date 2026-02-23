import "package:flutter/material.dart";
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/strings.dart";

InlineSpan getEquationText(
  String text, {
  required double superVerticalOffset,
  TextStyle? superStyle,
  SettingsRepository? settings,
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
  if (text.contains(".")) {
    return TextSpan(
      text: text.replaceAll(
        ".",
        mapDecimalSeparator(
          settings?.get(decimalSeparatorSetting) ?? DecimalSeparator.system,
        ),
      ),
    );
  }

  return TextSpan(
    text: getFormattedResult(text, noSeparator: true, settings: settings),
  );
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
