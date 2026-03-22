import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxdesign/colors.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/widgets.dart";
import "package:provider/provider.dart";

class LandscapeKeypad extends StatefulWidget {
  const LandscapeKeypad({
    required this.onDigitPress,
    required this.onConstantPress,
    required this.onOperationPress,
    required this.onFunctionPress,
    required this.onModePress,
    required this.onInvertPress,
    required this.onDecimalPress,
    required this.onDeletePress,
    required this.onClearPress,
    required this.onEqualPress,
    this.isInverted = false,
    this.fillHorizontalSpace = true,
    this.mode = "",
    super.key,
  });

  final Function(String value) onDigitPress;
  final Function(String value) onConstantPress;
  final Function(String value) onOperationPress;
  final Function(String value) onFunctionPress;
  final VoidCallback onModePress;
  final VoidCallback onInvertPress;
  final VoidCallback onDecimalPress;
  final VoidCallback onDeletePress;
  final VoidCallback onClearPress;
  final VoidCallback onEqualPress;

  final bool isInverted;
  final bool fillHorizontalSpace;
  final String mode;

  @override
  State<LandscapeKeypad> createState() => _LandscapeKeypadState();
}

class _LandscapeKeypadState extends State<LandscapeKeypad> {
  Timer? _longPressTimer;

  Map<String, String> get _keypadValues => {
    "{mode}": widget.mode,
    "{root}": widget.isInverted ? "x²" : "√",
    "{pi}": "π",
    "{digit_7}": "7",
    "{digit_8}": "8",
    "{digit_9}": "9",
    "{clear}": "AC",
    "{delete}": "C",
    "{invert}": "INV",
    "{power}": "^",
    "{factorial}": "!",
    "{digit_4}": "4",
    "{digit_5}": "5",
    "{digit_6}": "6",
    "{multiply}": "×",
    "{divide}": "÷",
    "{sin}": widget.isInverted ? "sin⁻¹" : "sin",
    "{cos}": widget.isInverted ? "cos⁻¹" : "cos",
    "{tan}": widget.isInverted ? "tan⁻¹" : "tan",
    "{digit_1}": "1",
    "{digit_2}": "2",
    "{digit_3}": "3",
    "{add}": "+",
    "{subtract}": "-",
    "{euler}": "e",
    "{ln}": widget.isInverted ? "eˣ" : "ln",
    "{log}": widget.isInverted ? "10ˣ" : "log",
    "{decimal}": _settings.get(swapDecimalZero)
        ? "0"
        : mapDecimalSeparator(_settings.get(decimalSeparator)),
    "{digit_0}": _settings.get(swapDecimalZero)
        ? mapDecimalSeparator(_settings.get(decimalSeparator))
        : "0",
    "{percent}": "%",
    "{bracket}": "()",
    "{equals}": "=",
  };

  SettingsRepository get _settings => context.read<SettingsRepository>();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorRepository>(
      builder: (context, repo, child) {
        return GridView.builder(
          shrinkWrap: true,
          itemCount: _keypadValues.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: widget.fillHorizontalSpace ? 2.0 : 1.2,
          ),
          itemBuilder: (context, index) {
            final key = _keypadValues.keys.elementAt(index);

            return Material(
              color: _getButtonBGColor(key),
              shape: _getButtonShape(key),
              child: InkWell(
                customBorder: _getButtonShape(key),
                onTap: () => _onButtonPress(key),
                onLongPress: () async {
                  if (key == "{delete}") {
                    _longPressTimer = Timer.periodic(
                      const Duration(milliseconds: 200),
                      (timer) {
                        _onButtonPress(key);
                      },
                    );
                  }
                },
                onLongPressUp: () {
                  if (key == "{delete}") {
                    _longPressTimer?.cancel();
                    _longPressTimer = null;
                  }
                },
                child: Center(child: _getButtonWidget(key)),
              ),
            );
          },
        );
      },
    );
  }

  String? _getButtonFont(String buttonKey) {
    return _settings.get(numpadFont);
  }

  Color _getButtonBGColor(String buttonKey) {
    switch (buttonKey) {
      case "{clear}":
      case "{equals}":
        return NxColors.nothingRed;
      case "{divide}":
      case "{multiply}":
      case "{subtract}":
      case "{add}":
        return _isDark ? NxColors.lightThemeCard : NxColors.darkThemeCard;
      default:
        return _isDark ? NxColors.darkThemeCard : NxColors.lightThemeCard;
    }
  }

  ShapeBorder? _getButtonShape(String buttonKey) {
    switch (buttonKey) {
      case "{invert}" when widget.isInverted:
        return RoundedRectangleBorder(
          side: const BorderSide(color: NxColors.nothingRed, width: 2),
          borderRadius: BorderRadiusGeometry.circular(16),
        );
      default:
        return RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),
        );
    }
  }

  Color? _getButtonFGColor(String buttonKey) {
    switch (buttonKey) {
      case "{clear}":
      case "{equals}":
        return NxColors.darkThemeText;
      case "{divide}":
      case "{multiply}":
      case "{subtract}":
      case "{add}":
        return _isDark ? NxColors.lightThemeText : NxColors.darkThemeText;
      default:
        return null;
    }
  }

  Widget _getButtonWidget(String buttonKey) {
    final font = _getButtonFont(buttonKey);
    final color = _getButtonFGColor(buttonKey);

    final functionsStyle = TextStyle(
      color: color,
      fontFamily: font,
      fontSize: 22,
    );
    final functionsStrut = const StrutStyle(
      forceStrutHeight: true,
      fontSize: 22,
    );
    final numpadStyle = TextStyle(color: color, fontFamily: font, fontSize: 24);
    final numpadStrut = const StrutStyle(forceStrutHeight: true, fontSize: 24);

    switch (buttonKey) {
      case "{sin}":
      case "{cos}":
      case "{tan}":
      case "{ln}":
      case "{log}":
      case "{root}":
      case "{invert}":
      case "{mode}":
      case "{pi}":
      case "{euler}":
      case "{factorial}":
      case "{power}":
        return Text(
          _keypadValues[buttonKey] ?? "",
          style: functionsStyle,
          strutStyle: functionsStrut,
          textAlign: TextAlign.center,
        );
      case "{delete}"
          when _settings.get(preferIconsToText) &&
              font == NxFonts.fontNDot:
        return Center(
          child: Text(
            "<<",
            style: numpadStyle,
            strutStyle: numpadStrut,
            textAlign: TextAlign.center,
          ),
        );
      case "{delete}":
        return const SizedBox.square(
          dimension: 28,
          child: NxIcon(path: NxIcon.backspace),
        );

      case "{bracket}"
          when font == NxFonts.fontNType || font == NxFonts.fontInter:
        return Text(
          "( )",
          style: numpadStyle,
          strutStyle: numpadStrut,
          textAlign: TextAlign.center,
        );
      default:
        return Text(
          _keypadValues[buttonKey] ?? "",
          style: numpadStyle,
          strutStyle: numpadStrut,
          textAlign: TextAlign.center,
        );
    }
  }

  void _onButtonPress(String buttonKey) {
    if (_settings.get(disableHaptics) != true) {
      HapticFeedback.vibrate();
    }

    switch (buttonKey) {
      case "{invert}":
        widget.onInvertPress.call();
      case "{mode}":
        widget.onModePress.call();
      case "{clear}":
        widget.onClearPress.call();
      case "{delete}":
        widget.onDeletePress.call();
      case "{equals}":
        widget.onEqualPress.call();
      case "{divide}":
      case "{multiply}":
      case "{subtract}":
      case "{add}":
        widget.onOperationPress.call(_keypadValues[buttonKey] ?? "");
      case "{percent}":
      case "{bracket}":
        widget.onOperationPress.call(buttonKey);
      case "{euler}":
      case "{pi}":
        widget.onConstantPress.call(_keypadValues[buttonKey] ?? "");
      case "{factorial}":
      case "{power}":
      case "{root}":
      case "{sin}":
      case "{cos}":
      case "{tan}":
      case "{log}":
      case "{ln}":
        widget.onFunctionPress.call(buttonKey);
      case "{decimal}" when _settings.get(swapDecimalZero):
        widget.onDigitPress.call("0");
      case "{decimal}":
        widget.onDecimalPress.call();
      case "{digit_0}" when _settings.get(swapDecimalZero):
        widget.onDecimalPress.call();
      case "{digit_0}":
        widget.onDigitPress.call("0");
      default:
        widget.onDigitPress.call(_keypadValues[buttonKey] ?? "");
    }
  }
}
