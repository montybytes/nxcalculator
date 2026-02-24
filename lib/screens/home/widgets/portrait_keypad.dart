import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/utils/ui.dart";
import "package:provider/provider.dart";

class PortraitKeypad extends StatefulWidget {
  const PortraitKeypad({
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
    super.key,
    this.isExtended = false,
    this.isInverted = false,
    this.mode = "",
  });

  final bool isExtended;
  final bool isInverted;
  final String mode;

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

  @override
  State<PortraitKeypad> createState() => _PortraitKeypadState();
}

class _PortraitKeypadState extends State<PortraitKeypad> {
  Map<String, String> get _basicKeypadValues => {
    "{clear}": "AC",
    "{bracket}": "()",
    "{percent}": "%",
    "{divide}": "÷",
    "{digit_7}": "7",
    "{digit_8}": "8",
    "{digit_9}": "9",
    "{multiply}": "×",
    "{digit_4}": "4",
    "{digit_5}": "5",
    "{digit_6}": "6",
    "{subtract}": "-",
    "{digit_1}": "1",
    "{digit_2}": "2",
    "{digit_3}": "3",
    "{add}": "+",
    "{decimal}": _settings.get(swapDecimalZeroSetting)
        ? "0"
        : mapDecimalSeparator(_settings.get(decimalSeparatorSetting)),
    "{digit_0}": _settings.get(swapDecimalZeroSetting)
        ? mapDecimalSeparator(_settings.get(decimalSeparatorSetting))
        : "0",
    "{delete}": "C",
    "{equals}": "=",
  };

  Map<String, String> get _extendedKeypadValues {
    return {
      "{root}": widget.isInverted ? "x" : "√",
      "{pi}": "π",
      "{power}": "^",
      "{factorial}": "!",
      "{mode}": widget.mode,
      "{sin}": widget.isInverted ? "arcsin(" : "sin(",
      "{cos}": widget.isInverted ? "arccos(" : "cos(",
      "{tan}": widget.isInverted ? "arctan(" : "tan(",
      "{invert}": "INV",
      "{euler}": "e",
      "{ln}": widget.isInverted ? "e" : "ln(",
      "{log}": widget.isInverted ? "10" : "log(",
    };
  }

  SettingsRepository get _settings => context.read<SettingsRepository>();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(
      builder: (context, settings, child) {
        return Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isExtended)
              GridView.builder(
                shrinkWrap: true,
                itemCount: _extendedKeypadValues.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: _getButtonSpacing(),
                  mainAxisSpacing: _getButtonSpacing(),
                ),
                itemBuilder: (context, index) {
                  final key = _extendedKeypadValues.keys.elementAt(index);

                  return Material(
                    shape: _getButtonShape(key),
                    color: _isDark ? darkThemeCard : lightThemeCard,
                    child: InkWell(
                      customBorder: _getButtonShape(key),
                      onTap: () => _onButtonPress(key),
                      child: Center(child: _getButtonWidget(key)),
                    ),
                  );
                },
              ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: _basicKeypadValues.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: widget.isExtended ? 1.3 : 1,
                crossAxisSpacing: _getButtonSpacing(),
                mainAxisSpacing: _getButtonSpacing(),
              ),
              itemBuilder: (context, index) {
                final key = _basicKeypadValues.keys.elementAt(index);

                return Material(
                  shape: _getButtonShape(key),
                  color: _getButtonBGColor(key),
                  child: InkWell(
                    customBorder: _getButtonShape(key),
                    onTap: () => _onButtonPress(key),
                    child: Center(child: _getButtonWidget(key)),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  double _getButtonSpacing() {
    final density = _settings.get(numpadDensitySetting);
    return density == NumpadDensity.dense ? 4 : 8;
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
    final shape = _settings.get(numpadButtonShapeSetting);
    final selectedBorderSide = buttonKey == "{invert}" && widget.isInverted
        ? const BorderSide(color: nothingRed, width: 2)
        : BorderSide.none;

    if (shape == NumpadShape.circular) {
      if (widget.isExtended) {
        return StadiumBorder(side: selectedBorderSide);
      }
      return const CircleBorder();
    }

    if (shape == NumpadShape.rounded) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(24),
        side: selectedBorderSide,
      );
    }

    if (widget.isExtended) {
      return StadiumBorder(side: selectedBorderSide);
    }

    switch (buttonKey) {
      case "{clear}":
      case "{delete}":
      case "{equals}":
        return RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(24),
        );
      default:
        return const CircleBorder();
    }
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
      case "{root}":
      case "{sin}":
      case "{cos}":
      case "{tan}":
        return _getRichTextWidget(buttonKey);
      case "{invert}":
      case "{mode}":
      case "{pi}":
      case "{euler}":
      case "{factorial}":
      case "{power}":
        return Text(
          _extendedKeypadValues[buttonKey] ?? "",
          style: TextStyle(
            color: _getButtonFGColor(buttonKey),
            fontFamily: _getButtonFont(buttonKey),
            fontSize: 24,
          ),
          strutStyle: const StrutStyle(forceStrutHeight: true, fontSize: 24),
          textAlign: TextAlign.center,
        );
      default:
        final font = _getButtonFont(buttonKey);

        return _settings.get(preferIconsToTextSetting) &&
                buttonKey == "{delete}"
            ? SizedBox.square(
                dimension: 48,
                child: font == "NDot"
                    ? Text(
                        "<<",
                        style: TextStyle(
                          color: _getButtonFGColor(buttonKey),
                          fontFamily: _getButtonFont(buttonKey),
                          fontSize: widget.isExtended ? 40 : 52,
                        ),
                        strutStyle: StrutStyle(
                          forceStrutHeight: true,
                          fontSize: widget.isExtended ? 40 : 52,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : _isDark
                    ? Image.asset("assets/icons/dark/backspace.png")
                    : Image.asset("assets/icons/light/backspace.png"),
              )
            : Text(
                _basicKeypadValues[buttonKey] ?? "",
                style: TextStyle(
                  color: _getButtonFGColor(buttonKey),
                  fontFamily: _getButtonFont(buttonKey),
                  fontSize: widget.isExtended ? 40 : 52,
                ),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  fontSize: widget.isExtended ? 40 : 52,
                ),
                textAlign: TextAlign.center,
              );
    }
  }

  Widget _getRichTextWidget(String buttonKey) {
    final font = _getButtonFont(buttonKey);

    final style = TextStyle(
      fontSize: font == "LetteraMono" ? 20 : 24,
      fontFamily: font,
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
      strutStyle: const StrutStyle(fontSize: 24, forceStrutHeight: true),
      textAlign: TextAlign.center,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: _extendedKeypadValues[buttonKey]
                ?.replaceAll("arc", "")
                .replaceAll("(", ""),
          ),
          if (superText.isNotEmpty)
            superscript(superText, fontSize: 20, family: style.fontFamily),
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
        widget.onOperationPress.call(_basicKeypadValues[buttonKey] ?? "");
      case "{percent}":
      case "{bracket}":
        widget.onOperationPress.call(buttonKey);
      case "{euler}":
      case "{pi}":
        widget.onConstantPress.call(_extendedKeypadValues[buttonKey] ?? "");
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
        final swapped = _settings.get(swapDecimalZeroSetting);
        if (swapped) {
          widget.onDigitPress.call("0");
        } else {
          widget.onDecimalPress.call();
        }
      default:
        final swapped = _settings.get(swapDecimalZeroSetting);
        if (swapped && buttonKey == "{digit_0}") {
          widget.onDecimalPress.call();
        } else {
          widget.onDigitPress.call(_basicKeypadValues[buttonKey] ?? "");
        }
    }
  }
}
