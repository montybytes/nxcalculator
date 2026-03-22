import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/models/setting.dart";
import "package:nxcalculator/registries/settings.dart";
import "package:nxcalculator/repositories/settings.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxdesign/colors.dart";
import "package:nxdesign/fonts.dart";
import "package:nxdesign/widgets.dart";
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
  Timer? _longPressTimer;

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
    "{decimal}": _settings.get(swapDecimalZero)
        ? "0"
        : mapDecimalSeparator(_settings.get(decimalSeparator)),
    "{digit_0}": _settings.get(swapDecimalZero)
        ? mapDecimalSeparator(_settings.get(decimalSeparator))
        : "0",
    "{delete}": "C",
    "{equals}": "=",
  };

  Map<String, String> get _extendedKeypadValues {
    return {
      "{root}": widget.isInverted ? "x²" : "√",
      "{pi}": "π",
      "{power}": "^",
      "{factorial}": "!",
      "{mode}": widget.mode,
      "{sin}": widget.isInverted ? "sin⁻¹" : "sin",
      "{cos}": widget.isInverted ? "cos⁻¹" : "cos",
      "{tan}": widget.isInverted ? "tan⁻¹" : "tan",
      "{invert}": "INV",
      "{euler}": "e",
      "{ln}": widget.isInverted ? "eˣ" : "ln",
      "{log}": widget.isInverted ? "10ˣ" : "log",
    };
  }

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
                    color: _isDark
                        ? NxColors.darkThemeCard
                        : NxColors.lightThemeCard,
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
            ),
          ],
        );
      },
    );
  }

  double _getButtonSpacing() {
    final density = _settings.get(numpadDensity);
    return density == NumpadDensity.dense ? 4 : 8;
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
    final shape = _settings.get(numpadButtonShape);
    final selectedBorderSide = buttonKey == "{invert}" && widget.isInverted
        ? const BorderSide(color: NxColors.nothingRed, width: 2)
        : BorderSide.none;

    switch (shape) {
      case NumpadShape.circular when widget.isExtended:
        return StadiumBorder(side: selectedBorderSide);
      case NumpadShape.circular:
        return const CircleBorder();
      case NumpadShape.rounded:
        return RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(24),
          side: selectedBorderSide,
        );
      case NumpadShape.mixed when widget.isExtended:
        return StadiumBorder(side: selectedBorderSide);
      default:
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

    final extendedStyle = TextStyle(
      color: color,
      fontFamily: font,
      fontSize: 24,
    );
    final extendedStrut = const StrutStyle(
      forceStrutHeight: true,
      fontSize: 24,
    );
    final numpadStyle = TextStyle(
      color: color,
      fontFamily: font,
      fontSize: widget.isExtended ? 40 : 52,
    );
    final numpadStrut = StrutStyle(
      forceStrutHeight: true,
      fontSize: widget.isExtended ? 40 : 52,
    );

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
          _extendedKeypadValues[buttonKey] ?? "",
          style: extendedStyle,
          strutStyle: extendedStrut,
          textAlign: TextAlign.center,
        );
      case "{delete}"
          when _settings.get(preferIconsToText) && font == NxFonts.fontNDot:
        return SizedBox.square(
          dimension: 48,
          child: Text(
            "<<",
            style: numpadStyle,
            strutStyle: StrutStyle(
              forceStrutHeight: true,
              height: widget.isExtended ? 1.2 : 0.9,
              fontSize: widget.isExtended ? 40 : 52,
            ),
            textAlign: TextAlign.center,
          ),
        );
      case "{delete}":
        return const SizedBox.square(
          dimension: 48,
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
          _basicKeypadValues[buttonKey] ?? "",
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
      case "{decimal}" when _settings.get(swapDecimalZero):
        widget.onDigitPress.call("0");
      case "{decimal}":
        widget.onDecimalPress.call();
      case "{digit_0}" when _settings.get(swapDecimalZero):
        widget.onDecimalPress.call();
      case "{digit_0}":
        widget.onDigitPress.call("0");
      default:
        widget.onDigitPress.call(_basicKeypadValues[buttonKey] ?? "");
    }
  }
}
