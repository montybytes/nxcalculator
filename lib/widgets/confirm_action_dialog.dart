import "package:flutter/material.dart";
import "package:nxcalculator/theme/constants.dart";

class ConfirmActionDialog extends StatelessWidget {
  const ConfirmActionDialog({
    required this.titleText,
    required this.infoText,
    super.key,
    this.confirmText,
    this.cancelText,
  });

  final String titleText;
  final String infoText;
  final String? confirmText;
  final String? cancelText;

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return AlertDialog(
      actionsPadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      title: Text(titleText, textAlign: TextAlign.center),
      content: Text(infoText, textAlign: TextAlign.center),
      actions: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: _buildActionButtonStyle(isConfirm: true, isDark: isDark),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("OK"),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: _buildActionButtonStyle(isConfirm: false, isDark: isDark),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("CANCEL"),
          ),
        ),
      ],
    );
  }

  ButtonStyle _buildActionButtonStyle({
    bool isConfirm = false,
    bool isDark = false,
  }) {
    return TextButton.styleFrom(
      foregroundColor: isConfirm
          ? isDark
                ? darkThemeText
                : lightThemeText
          : const Color(0xFFD71921),
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: isDark ? darkThemeListItem : lightThemeListItem,
      shape: isConfirm ? startBorderRadius : endBorderRadius,
    );
  }
}
