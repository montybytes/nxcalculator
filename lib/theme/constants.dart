import "package:flutter/material.dart";

const defaultFontFamily = "Inter";

const nothingRed = Color(0xFFD71921);

const lightThemeText = Color(0xFF1C1C1C);
const darkThemeText = Color(0xFFEFEFEF);

const lightThemeBackground = Color(0xFFF2F2F2);
const darkThemeBackground = Color(0xFF000000);

const lightThemeCard = Color(0xFFFFFFFF);
const darkThemeCard = Color(0xFF1C1C1C);

const lightThemeListItem = Color(0xFFFFFFFF);
const darkThemeListItem = Color(0xFF292929);

const defaultBorderRadius = RoundedRectangleBorder(
  borderRadius: BorderRadiusGeometry.vertical(
    top: Radius.circular(4),
    bottom: Radius.circular(4),
  ),
);

final largeBorderRadius = const RoundedRectangleBorder(
  borderRadius: BorderRadiusGeometry.vertical(
    top: Radius.circular(12),
    bottom: Radius.circular(12),
  ),
);

const startBorderRadius = RoundedRectangleBorder(
  borderRadius: BorderRadiusGeometry.vertical(
    top: Radius.circular(12),
    bottom: Radius.circular(4),
  ),
);

const endBorderRadius = RoundedRectangleBorder(
  borderRadius: BorderRadiusGeometry.vertical(
    top: Radius.circular(4),
    bottom: Radius.circular(12),
  ),
);

const textSelectionDefaultTheme = TextSelectionThemeData(
  cursorColor: nothingRed,
  selectionColor: nothingRed,
  selectionHandleColor: nothingRed,
);

const cardDefaultTheme = CardThemeData(
  elevation: 0,
  clipBehavior: Clip.antiAlias,
  margin: EdgeInsets.zero,
);

const appBarDefaultTheme = AppBarTheme(elevation: 0, scrolledUnderElevation: 0);
