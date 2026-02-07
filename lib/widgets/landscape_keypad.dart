import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/repositories/calculator.dart";
import "package:nxcalculator/theme/constants.dart";
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
    "{decimal}": ".",
    "{digit_0}": "0",
    "{percent}": "%",
    "{bracket}": "()",
    "{equals}": "=",
  };

  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorRepository>(
      builder: (context, repo, child) => GridView.builder(
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
      ),
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
        final fontSize = 20.0;
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
        final fontSize = 24.0;
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
        final fontSize = 32.0;
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
    }
  }

  Widget _getRichTextWidget(String buttonKey) {
    return RichText(
      strutStyle: const StrutStyle(fontSize: 16, forceStrutHeight: true),
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 18,
          fontFamily: "LetteraMono",
          color: _isDark ? darkThemeText : lightThemeText,
        ),
        children: [
          TextSpan(
            text: _keypadValues[buttonKey]
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
