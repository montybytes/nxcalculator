import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxdesign/colors.dart";
import "package:nxdesign/fonts.dart";
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
    "{sin}": widget.isInverted ? "arcsin(" : "sin(",
    "{cos}": widget.isInverted ? "arccos(" : "cos(",
    "{tan}": widget.isInverted ? "arctan(" : "tan(",
    "{digit_1}": "1",
    "{digit_2}": "2",
    "{digit_3}": "3",
    "{add}": "+",
    "{subtract}": "-",
    "{euler}": "e",
    "{ln}": widget.isInverted ? "eˣ" : "ln(",
    "{log}": widget.isInverted ? "10ˣ" : "log(",
    "{decimal}": mapDecimalSeparator(_settings.get(decimalSeparatorSetting)),
    "{digit_0}": "0",
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
    final font = _settings.get(numpadFontSetting);

    if (buttonKey.contains("digit")) {
      return font;
    }

    return switch (buttonKey) {
      "{divide}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      "{multiply}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      "{subtract}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      "{add}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      "{equals}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      "{pi}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      "{power}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      "{root}" when font == NxFonts.fontNType && !widget.isInverted =>
        NxFonts.fontLettera,
      "{factorial}" when font == NxFonts.fontNType => NxFonts.fontLettera,
      _ => font,
    };
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
    return RoundedRectangleBorder(
      side: buttonKey == "{invert}" && widget.isInverted
          ? const BorderSide(color: NxColors.nothingRed, width: 2)
          : BorderSide.none,
      borderRadius: BorderRadiusGeometry.circular(16),
    );
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
    switch (buttonKey) {
      case "{ln}":
      case "{log}":
      case "{sin}":
      case "{cos}":
      case "{tan}":
      case "{root}":
        return _getRichTextWidget(buttonKey);
      case "{invert}":
      case "{mode}":
        final fontSize = 22.0;
        return Text(
          _keypadValues[buttonKey] ?? "",
          style: TextStyle(
            color: _getButtonFGColor(buttonKey),
            fontFamily: _getButtonFont(buttonKey),
            fontSize: fontSize,
          ),
          strutStyle: StrutStyle(forceStrutHeight: true, fontSize: fontSize),
          textAlign: TextAlign.center,
        );
      case "{pi}":
      case "{euler}":
      case "{factorial}":
      case "{power}":
        final fontSize = 22.0;
        return Text(
          _keypadValues[buttonKey] ?? "",
          style: TextStyle(
            color: _getButtonFGColor(buttonKey),
            fontFamily: _getButtonFont(buttonKey),
            fontSize: fontSize,
          ),
          strutStyle: StrutStyle(forceStrutHeight: true, fontSize: fontSize),
          textAlign: TextAlign.center,
        );
      default:
        final font = _getButtonFont(buttonKey);
        final fontSize = 22.0;

        return _settings.get(preferIconsToTextSetting) &&
                buttonKey == "{delete}"
            ? font == NxFonts.fontNDot
                  ? Center(
                      child: Text(
                        "<<",
                        style: TextStyle(
                          color: _getButtonFGColor(buttonKey),
                          fontFamily: _getButtonFont(buttonKey),
                          fontSize: fontSize,
                        ),
                        strutStyle: StrutStyle(
                          fontSize: fontSize,
                          forceStrutHeight: true,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SizedBox.square(
                      dimension: 28,
                      child: _isDark
                          ? Image.asset("assets/icons/dark/backspace.png")
                          : Image.asset("assets/icons/light/backspace.png"),
                    )
            : Text(
                buttonKey == "{bracket}" &&
                        (font == NxFonts.fontNType || font == NxFonts.fontInter)
                    ? "(  )"
                    : _keypadValues[buttonKey] ?? "",
                style: TextStyle(
                  color: _getButtonFGColor(buttonKey),
                  fontFamily: _getButtonFont(buttonKey),
                  fontSize: fontSize,
                ),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              );
    }
  }

  Widget _getRichTextWidget(String buttonKey) {
    final font = _getButtonFont(buttonKey);
    final fontSize = 22.0;

    final style = TextStyle(
      fontSize: fontSize,
      fontFamily: font,
      letterSpacing: font == NxFonts.fontLettera ? -4 : 0,
      color: _isDark ? NxColors.darkThemeText : NxColors.lightThemeText,
    );

    final text = _keypadValues[buttonKey]
        ?.replaceAll("arc", "")
        .replaceAll("(", "");

    final superText = switch (buttonKey) {
      "{sin}" when widget.isInverted => "⁻¹",
      "{cos}" when widget.isInverted => "⁻¹",
      "{tan}" when widget.isInverted => "⁻¹",
      _ => "",
    };

    final displayText = "$text$superText";

    return Text(
      displayText,
      style: style,
      strutStyle: StrutStyle(fontSize: style.fontSize, forceStrutHeight: true),
      textAlign: TextAlign.center,
    );
  }

  void _onButtonPress(String buttonKey) {
    if (_settings.get(disableHapticSetting) != true) {
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
      case "{decimal}":
        widget.onDecimalPress.call();
      default:
        widget.onDigitPress.call(_keypadValues[buttonKey] ?? "");
    }
  }
}
