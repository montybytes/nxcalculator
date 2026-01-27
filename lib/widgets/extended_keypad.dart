import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/theme/constants.dart";

class ExtendedKeypad extends StatefulWidget {
  const ExtendedKeypad({
    required this.onModePress,
    required this.onInvertPress,
    required this.onFunctionPress,
    super.key,
  });

  final Function(String value) onModePress;
  final Function(bool value) onInvertPress;
  final Function(String value) onFunctionPress;

  @override
  State<ExtendedKeypad> createState() => _ExtendedKeypadState();
}

class _ExtendedKeypadState extends State<ExtendedKeypad> {
  final _keypadValues = [
    "{root}",
    "{pi}",
    "{power}",
    "{factorial}",
    "{mode}",
    "{sin}",
    "{cos}",
    "{tan}",
    "{inverse}",
    "{exponent}",
    "{ln}",
    "{log}",
  ];

  final _fontSize = 24.0;
  final _fontFamily = "Ntype-82";

  var _inverted = false;
  var _mode = "DEG";

  TextStyle get _fontStyle =>
      TextStyle(fontFamily: _fontFamily, fontSize: _fontSize);
  StrutStyle get _strutStyle =>
      StrutStyle(fontSize: _fontSize, forceStrutHeight: true);
  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _keypadValues.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final value = _keypadValues[index];

        return Material(
          color: _isDark ? darkThemeCard : lightThemeCard,
          shape: StadiumBorder(
            side: value == "{inverse}" && _inverted
                ? const BorderSide(color: nothingRed, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => _onButtonPress(value),
            child: Center(
              child: RichText(
                strutStyle: _strutStyle,
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: _fontStyle.copyWith(
                    fontFamily: "LetteraMono",
                    color: _isDark ? darkThemeText : lightThemeText,
                  ),
                  children: _getButtonText(value),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<InlineSpan> _getButtonText(String value) {
    switch (value) {
      case "{root}":
        return [
          TextSpan(text: _inverted ? "x" : "√"),
          if (_inverted) superscript("2"),
        ];
      case "{pi}":
        return [const TextSpan(text: "π")];
      case "{power}":
        return [const TextSpan(text: "^")];
      case "{factorial}":
        return [const TextSpan(text: "!")];
      case "{mode}":
        return [TextSpan(text: _mode)];
      case "{inverse}":
        return [const TextSpan(text: "INV")];
      case "{exponent}":
        return [const TextSpan(text: "e")];
      case "{ln}":
        return [
          TextSpan(text: _inverted ? "e" : "ln"),
          if (_inverted) superscript("x"),
        ];
      case "{log}":
        return [
          TextSpan(text: _inverted ? "10" : "log"),
          if (_inverted) superscript("x"),
        ];
      default:
        return [
          TextSpan(text: value.replaceAll("{", "").replaceAll("}", "")),
          if (_inverted) superscript("-1"),
        ];
    }
  }

  WidgetSpan superscript(String text) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.top,
      child: Transform.translate(
        offset: const Offset(0, -6),
        child: Text(
          text,
          textScaler: const TextScaler.linear(0.7),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _onButtonPress(String value) {
    HapticFeedback.vibrate();

    switch (value) {
      case "{inverse}":
        setState(() => _inverted = !_inverted);
        widget.onInvertPress.call(_inverted);
      case "{mode}":
        setState(() => _mode = _mode == "DEG" ? "RAD" : "DEG");
        widget.onModePress.call(_mode);
      default:
        widget.onFunctionPress.call(value);
    }
  }
}
