import "package:flutter/material.dart";

class ResultTextField extends StatelessWidget {
  const ResultTextField({
    required this.result,
    this.error,
    this.style,
    super.key,
  });

  final String result;
  final String? error;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: SelectableText.rich(
        maxLines: 1,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        TextSpan(
          text: result == "" && error != null ? error : result,
          style: style,
        ),
      ),
    );
  }
}
