import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  canvasColor: lightThemeBackground,
  scaffoldBackgroundColor: lightThemeBackground,
  appBarTheme: appBarDefaultTheme.copyWith(
    backgroundColor: lightThemeBackground,
    foregroundColor: lightThemeText,
  ),
  textSelectionTheme: textSelectionDefaultTheme,
  textTheme: ThemeData().textTheme.apply(
    bodyColor: lightThemeText,
    displayColor: lightThemeText,
  ),
  cardTheme: cardDefaultTheme.copyWith(color: lightThemeCard),
  dialogTheme: const DialogThemeData(backgroundColor: lightThemeBackground),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: lightThemeBackground,
  ),
  dividerColor: lightThemeText,
);
