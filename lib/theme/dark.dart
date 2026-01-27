import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkThemeBackground,
  primaryColorDark: darkThemeCard,
  appBarTheme: appBarDefaultTheme.copyWith(
    iconTheme: const IconThemeData(color: darkThemeText),
    backgroundColor: darkThemeBackground,
    foregroundColor: darkThemeText,
  ),
  textTheme: ThemeData().textTheme.apply(
    bodyColor: darkThemeText,
    displayColor: darkThemeText,
  ),
  cardTheme: cardDefaultTheme.copyWith(color: darkThemeCard),
  floatingActionButtonTheme: fabDefaultTheme,
  elevatedButtonTheme: buttonDefaultTheme,
  iconTheme: const IconThemeData(color: darkThemeText),
  listTileTheme: listTileDefaultTheme.copyWith(
    textColor: darkThemeText,
    tileColor: darkThemeListItem,
  ),
  expansionTileTheme: expansionTileDefaultTheme.copyWith(
    backgroundColor: darkThemeListItem,
    textColor: darkThemeText,
    iconColor: darkThemeText,
    collapsedBackgroundColor: darkThemeListItem,
    collapsedTextColor: darkThemeText,
    collapsedIconColor: darkThemeText,
  ),
  checkboxTheme: checkboxDefaultTheme,
  switchTheme: switchDefaultTheme,
  textButtonTheme: textButtonDefaultTheme,
  dialogTheme: const DialogThemeData(backgroundColor: darkThemeCard),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: darkThemeCard),
  inputDecorationTheme: textInputDefaultDecoration.copyWith(
    fillColor: darkThemeListItem,
  ),
  dividerColor: darkThemeText,
  timePickerTheme: timePickerDefaultTheme.copyWith(
    dialHandColor: nothingRed,
    dialTextColor: darkThemeText,
    dialBackgroundColor: darkThemeListItem,
    dayPeriodColor: nothingRed,
    dayPeriodTextColor: darkThemeText,
    hourMinuteColor: darkThemeListItem,
    hourMinuteTextColor: darkThemeText,
    backgroundColor: darkThemeCard,
    dayPeriodBorderSide: const BorderSide(color: darkThemeListItem),
    inputDecorationTheme: textInputDefaultDecoration.copyWith(
      fillColor: darkThemeListItem,
      contentPadding: EdgeInsets.zero,
    ),
  ),
  textSelectionTheme: textSelectionDefaultTheme,
  chipTheme: chipDefaultTheme,
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStateColor.resolveWith((states) {
        return darkThemeText;
      }),
    ),
  ),
  canvasColor: darkThemeBackground,
);
