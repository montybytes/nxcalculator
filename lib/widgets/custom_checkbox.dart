import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomCheckbox({required this.value, this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 250);

    return SizedBox.square(
      dimension: 48,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onChanged?.call(!value),
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: value ? lightThemeCard : null,
                borderRadius: BorderRadius.circular(4),
                border: value
                    ? null
                    : Border.all(color: lightThemeCard, width: 2),
              ),
              child: Center(
                child: AnimatedOpacity(
                  duration: duration,
                  opacity: value ? 1.0 : 0.0,
                  child: Image.asset("assets/icons/check.png", width: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
