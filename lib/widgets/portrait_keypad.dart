import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/theme/constants.dart";
import "package:nxcalculator/utils/strings.dart";
import "package:nxcalculator/utils/ui.dart";

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
    "{decimal}": getLocaleDecimalSeparator(),
    "{digit_0}": "0",
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

  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
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
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
  }

  String? _getButtonFont(String buttonKey) {
    if (buttonKey.contains("digit")) {
      return "Ntype-82";
    }

    switch (buttonKey) {
      case "{clear}":
      case "{delete}":
      case "{decimal}":
        return "Ntype-82";
      default:
        return "LetteraMono";
    }
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
    if (widget.isExtended) {
      return StadiumBorder(
        side: buttonKey == "{invert}" && widget.isInverted
            ? const BorderSide(color: nothingRed, width: 2)
            : BorderSide.none,
      );
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
        return Text(
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
    return RichText(
      strutStyle: const StrutStyle(fontSize: 24, forceStrutHeight: true),
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 24,
          fontFamily: "LetteraMono",
          color: _isDark ? darkThemeText : lightThemeText,
        ),
        children: [
          TextSpan(
            text: _extendedKeypadValues[buttonKey]
                ?.replaceAll("arc", "")
                .replaceAll("(", ""),
          ),
          if (buttonKey == "{root}" && widget.isInverted) superscript("2"),
          if (widget.isInverted)
            if (["{sin}", "{cos}", "{tan}"].contains(buttonKey))
              superscript("-1")
            else if ((["{ln}", "{log}"]).contains(buttonKey))
              superscript("x"),
        ],
      ),
    );
  }

  void _onButtonPress(String buttonKey) {
    HapticFeedback.vibrate();

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
        widget.onDecimalPress.call();
      default:
        widget.onDigitPress.call(_basicKeypadValues[buttonKey] ?? "");
    }
  }
}
