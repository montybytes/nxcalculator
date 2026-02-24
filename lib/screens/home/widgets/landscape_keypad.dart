import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/utils/ui.dart";
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
  final String mode;

  @override
  State<LandscapeKeypad> createState() => _LandscapeKeypadState();
}

class _LandscapeKeypadState extends State<LandscapeKeypad> {
  Map<String, String> get _keypadValues => {
    "{mode}": widget.mode,
    "{root}": widget.isInverted ? "x" : "√",
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
    "{ln}": widget.isInverted ? "e" : "ln(",
    "{log}": widget.isInverted ? "10" : "log(",
    "{decimal}": mapDecimalSeparator(_settings.get(decimalSeparatorSetting)),
    "{digit_0}": "0",
    "{percent}": "%",
    "{bracket}": "()",
    "{equals}": "=",
  };

  SettingsRepository get _settings => context.read<SettingsRepository>();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorRepository>(
      builder: (context, repo, child) {
        return GridView.builder(
          shrinkWrap: true,
          itemCount: _keypadValues.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final key = _keypadValues.keys.elementAt(index);

            return Material(
              color: _getButtonBGColor(key),
              shape: _getButtonShape(key),
              child: InkWell(
                customBorder: _getButtonShape(key),
                onTap: () => _onButtonPress(key),
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
      "{divide}" when font == "NType" => "LetteraMono",
      "{multiply}" when font == "NType" => "LetteraMono",
      "{subtract}" when font == "NType" => "LetteraMono",
      "{add}" when font == "NType" => "LetteraMono",
      "{equals}" when font == "NType" => "LetteraMono",
      "{pi}" when font == "NType" => "LetteraMono",
      "{power}" when font == "NType" => "LetteraMono",
      "{root}" when font == "NType" && !widget.isInverted => "LetteraMono",
      "{factorial}" when font == "NType" => "LetteraMono",
      _ => font,
    };
  }

  Color _getButtonBGColor(String buttonKey) {
    switch (buttonKey) {
      case "{clear}":
      case "{equals}":
        return nothingRed;
      case "{divide}":
      case "{multiply}":
      case "{subtract}":
      case "{add}":
        return _isDark ? lightThemeCard : darkThemeCard;
      default:
        return _isDark ? darkThemeCard : lightThemeCard;
    }
  }

  ShapeBorder? _getButtonShape(String buttonKey) {
    return RoundedRectangleBorder(
      side: buttonKey == "{invert}" && widget.isInverted
          ? const BorderSide(color: nothingRed, width: 2)
          : BorderSide.none,
      borderRadius: BorderRadiusGeometry.circular(16),
    );
  }

  Color? _getButtonFGColor(String buttonKey) {
    switch (buttonKey) {
      case "{clear}":
      case "{equals}":
        return darkThemeText;
      case "{divide}":
      case "{multiply}":
      case "{subtract}":
      case "{add}":
        return _isDark ? lightThemeText : darkThemeText;
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
            ? font == "NDot"
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
                _keypadValues[buttonKey] ?? "",
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
      letterSpacing: font == "LetteraMono" ? -4 : 0,
      color: _isDark ? darkThemeText : lightThemeText,
    );

    final superText = switch (buttonKey) {
      "{root}" when widget.isInverted => "2",
      "{sin}" when widget.isInverted => "-1",
      "{cos}" when widget.isInverted => "-1",
      "{tan}" when widget.isInverted => "-1",
      "{log}" when widget.isInverted => "x",
      "{ln}" when widget.isInverted => "x",
      _ => "",
    };

    return RichText(
      strutStyle: StrutStyle(fontSize: fontSize, forceStrutHeight: true),
      textAlign: TextAlign.center,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: _keypadValues[buttonKey]
                ?.replaceAll("arc", "")
                .replaceAll("(", ""),
          ),
          if (superText.isNotEmpty)
            superscript(superText, fontSize: 16, family: style.fontFamily),
        ],
      ),
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
