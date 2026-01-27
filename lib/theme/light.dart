import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: lightThemeBackground,
  appBarTheme: appBarDefaultTheme.copyWith(
    iconTheme: const IconThemeData(color: lightThemeText),
    backgroundColor: lightThemeBackground,
    foregroundColor: lightThemeText,
  ),
  textTheme: ThemeData().textTheme.apply(
    bodyColor: lightThemeText,
    displayColor: lightThemeText,
  ),
  cardTheme: cardDefaultTheme.copyWith(color: lightThemeCard),
  floatingActionButtonTheme: fabDefaultTheme,
  elevatedButtonTheme: buttonDefaultTheme,
  iconTheme: const IconThemeData(color: lightThemeText),
  listTileTheme: listTileDefaultTheme.copyWith(
    textColor: lightThemeText,
    tileColor: lightThemeListItem,
  ),
  expansionTileTheme: expansionTileDefaultTheme.copyWith(
    backgroundColor: lightThemeListItem,
    textColor: lightThemeText,
    iconColor: lightThemeText,
    collapsedBackgroundColor: lightThemeListItem,
    collapsedTextColor: lightThemeText,
    collapsedIconColor: lightThemeText,
  ),
  checkboxTheme: checkboxDefaultTheme,
  switchTheme: switchDefaultTheme,
  textButtonTheme: textButtonDefaultTheme,
  dialogTheme: const DialogThemeData(backgroundColor: lightThemeBackground),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: lightThemeBackground,
  ),
  inputDecorationTheme: textInputDefaultDecoration.copyWith(
    fillColor: lightThemeListItem,
  ),
  dividerColor: lightThemeText,
  timePickerTheme: timePickerDefaultTheme.copyWith(
    dialHandColor: nothingRed,
    dialTextColor: lightThemeText,
    dialBackgroundColor: lightThemeListItem,
    dayPeriodColor: nothingRed,
    dayPeriodTextColor: lightThemeText,
    hourMinuteColor: lightThemeListItem,
    hourMinuteTextColor: lightThemeText,
    backgroundColor: lightThemeBackground,
    dayPeriodBorderSide: const BorderSide(color: lightThemeListItem),
    inputDecorationTheme: textInputDefaultDecoration.copyWith(
      fillColor: lightThemeListItem,
      contentPadding: EdgeInsets.zero,
    ),
  ),
  textSelectionTheme: textSelectionDefaultTheme,
  chipTheme: chipDefaultTheme,
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStateColor.resolveWith((states) {
        return lightThemeText;
      }),
    ),
  ),
  canvasColor: lightThemeBackground,
);
