import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  canvasColor: darkThemeBackground,
  scaffoldBackgroundColor: darkThemeBackground,
  appBarTheme: appBarDefaultTheme.copyWith(
    backgroundColor: darkThemeBackground,
    foregroundColor: darkThemeText,
  ),
  textSelectionTheme: textSelectionDefaultTheme,
  textTheme: ThemeData().textTheme.apply(
    bodyColor: darkThemeText,
    displayColor: darkThemeText,
  ),
  cardTheme: cardDefaultTheme.copyWith(color: darkThemeCard),
  dialogTheme: const DialogThemeData(backgroundColor: darkThemeCard),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: darkThemeCard),
  dividerColor: darkThemeText,
);
