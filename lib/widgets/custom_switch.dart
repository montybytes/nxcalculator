import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch({required this.value, this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    const width = 48.0;
    const height = 48.0;
    const duration = Duration(milliseconds: 250);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? lightThemeBackground : darkThemeBackground;
    final inactiveColor = isDark
        ? const Color(0xFF484848)
        : const Color(0xFFC8C8C8);
    final thumbColor = isDark ? darkThemeBackground : lightThemeBackground;

    return SizedBox(
      height: height,
      width: width,
      child: GestureDetector(
        onTap: () => onChanged?.call(!value),
        child: Center(
          child: AnimatedContainer(
            height: 24,
            width: double.infinity,
            duration: duration,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              color: value ? activeColor : inactiveColor,
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  duration: duration,
                  curve: Curves.easeInOut,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: thumbColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
