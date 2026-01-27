import "package:flutter/material.dart";

const nothingRed = Color(0xFFD71921);

const lightThemeText = Color(0xFF1C1C1C);
const darkThemeText = Color(0xFFEFEFEF);

const lightThemeBackground = Color(0xFFF2F2F2);
const darkThemeBackground = Color(0xFF000000);

const lightThemeCard = Color(0xFFFFFFFF);
const darkThemeCard = Color(0xFF1C1C1C);

const lightThemeListItem = Color(0xFFFFFFFF);
const darkThemeListItem = Color(0xFF292929);

final defaultBorderRadius = RoundedRectangleBorder(
  borderRadius: BorderRadiusGeometry.circular(4),
);

final largeBorderRadius = RoundedRectangleBorder(
  borderRadius: BorderRadiusGeometry.circular(12),
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

final textInputDefaultShape = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(color: Colors.transparent),
);

final textInputDefaultDecoration = InputDecorationTheme(
  filled: true,
  border: textInputDefaultShape,
  enabledBorder: textInputDefaultShape,
  focusedBorder: textInputDefaultShape.copyWith(
    borderSide: const BorderSide(color: nothingRed, width: 1),
  ),
);

final timePickerDefaultTheme = TimePickerThemeData(
  hourMinuteShape: largeBorderRadius,
  dayPeriodShape: largeBorderRadius,
);

const textSelectionDefaultTheme = TextSelectionThemeData(
  cursorColor: nothingRed,
  selectionColor: nothingRed,
  selectionHandleColor: nothingRed,
);

final textButtonDefaultTheme = TextButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateColor.resolveWith((states) {
      return states.contains(WidgetState.selected) ? nothingRed : nothingRed;
    }),
    foregroundColor: WidgetStateColor.resolveWith((states) {
      return const Color(0xFFEFEFEF);
    }),
  ),
);

final switchDefaultTheme = SwitchThemeData(
  trackColor: WidgetStateColor.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? const Color(0xFF697884)
        : const Color(0xFF42484C);
  }),
  thumbColor: WidgetStateColor.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? const Color(0xFFC9E7FD)
        : const Color(0xFF8B9296);
  }),
  trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
    return 0;
  }),
);

final checkboxDefaultTheme = CheckboxThemeData(
  shape: defaultBorderRadius,
  fillColor: WidgetStateColor.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? darkThemeText
        : Colors.transparent;
  }),
  checkColor: WidgetStateColor.resolveWith((states) {
    return states.contains(WidgetState.selected)
        ? darkThemeBackground
        : Colors.transparent;
  }),
  side: const BorderSide(width: 2),
);

final expansionTileDefaultTheme = ExpansionTileThemeData(
  shape: defaultBorderRadius,
);

final listTileDefaultTheme = ListTileThemeData(shape: defaultBorderRadius);

const fabDefaultTheme = FloatingActionButtonThemeData(
  backgroundColor: nothingRed,
  foregroundColor: darkThemeText,
  shape: CircleBorder(),
  elevation: 0,
  focusElevation: 0,
  hoverElevation: 0,
  highlightElevation: 0,
);

final buttonDefaultTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateColor.resolveWith((states) {
      return nothingRed;
    }),
    foregroundColor: WidgetStateColor.resolveWith((states) {
      return const Color(0xFFEFEFEF);
    }),
    shape: WidgetStatePropertyAll(largeBorderRadius),
  ),
);

const bottomNavDefaultTheme = BottomNavigationBarThemeData(
  type: BottomNavigationBarType.fixed,
  selectedIconTheme: IconThemeData(color: nothingRed),
  selectedItemColor: nothingRed,
  enableFeedback: true,
  elevation: 0,
);

const cardDefaultTheme = CardThemeData(
  elevation: 0,
  clipBehavior: Clip.antiAlias,
  margin: EdgeInsets.zero,
);

const appBarDefaultTheme = AppBarTheme(elevation: 0, scrolledUnderElevation: 0);

final chipDefaultTheme = const ChipThemeData(
  showCheckmark: false,
  selectedColor: nothingRed,
);
