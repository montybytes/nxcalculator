import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:nxcalculator/theme/constants.dart";

class BasicKeypad extends StatefulWidget {
  const BasicKeypad({
    required this.isExtended,
    required this.onDigitPress,
    required this.onOperationPress,
    required this.onDecimalPress,
    required this.onEqualPress,
    required this.onDeletePress,
    required this.onClearPress,
    super.key,
  });

  final bool isExtended;
  final Function(String value) onDigitPress;
  final Function(String value) onOperationPress;
  final VoidCallback onDecimalPress;
  final VoidCallback onEqualPress;
  final VoidCallback onDeletePress;
  final VoidCallback onClearPress;

  @override
  State<BasicKeypad> createState() => _BasicKeypadState();
}

class _BasicKeypadState extends State<BasicKeypad> {
  final _keypadValues = [
    "{clear}",
    "{bracket}",
    "{percent}",
    "{divide}",
    "7",
    "8",
    "9",
    "{multiply}",
    "4",
    "5",
    "6",
    "{subtract}",
    "1",
    "2",
    "3",
    "{add}",
    "{decimal}",
    "0",
    "{delete}",
    "{equals}",
  ];

  bool get _isDark =>
      MediaQuery.of(context).platformBrightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _keypadValues.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: widget.isExtended ? 1.3 : 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final value = _keypadValues[index];

        return Material(
          color: _getButtonColor(value),
          shape: _getButtonShape(value),
          child: InkWell(
            customBorder: _getButtonShape(value),
            onTap: () => _onButtonPress(value),
            child: Center(
              child: Text(
                _getButtonText(value),
                style: TextStyle(
                  color: _getButtonTextColor(value),
                  fontFamily: _getButtonFont(value),
                  fontSize: widget.isExtended ? 40 : 52,
                ),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  fontSize: widget.isExtended ? 40 : 52,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  String? _getButtonFont(String value) {
    switch (value) {
      case "{add}":
      case "{equals}":
      case "{divide}":
      case "{multiply}":
      case "{subtract}":
      case "{percent}":
      case "{bracket}":
      case "{decimal}":
        return "LetteraMono";
      default:
        return "Ntype-82";
    }
  }

  Color _getButtonColor(String value) {
    switch (value) {
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

  ShapeBorder? _getButtonShape(String value) {
    if (widget.isExtended) {
      return const StadiumBorder();
    }

    switch (value) {
      case "{delete}":
      case "{equals}":
        return RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(24),
        );
      default:
        return const CircleBorder();
    }
  }

  Color? _getButtonTextColor(String value) {
    switch (value) {
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

  String _getButtonText(String value) {
    switch (value) {
      case "{clear}":
        return "AC";
      case "{equals}":
        return "=";
      case "{divide}":
        return "÷";
      case "{multiply}":
        return "×";
      case "{subtract}":
        return "-";
      case "{add}":
        return "+";
      case "{delete}":
        return "C";
      case "{percent}":
        return "%";
      case "{bracket}":
        return "()";
      case "{decimal}":
        return ".";
      default:
        return value;
    }
  }

  void _onButtonPress(String value) {
    HapticFeedback.vibrate();

    switch (value) {
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
        widget.onOperationPress.call(_getButtonText(value));
      case "{percent}":
      case "{bracket}":
        widget.onOperationPress.call(value);
      case "{decimal}":
        widget.onDecimalPress.call();
      default:
        widget.onDigitPress.call(value);
    }
  }
}
