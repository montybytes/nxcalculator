import "package:flutter/material.dart";

class ResultTextField extends StatelessWidget {
  const ResultTextField({required this.result, super.key});

  final String result;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: SelectableText.rich(
        maxLines: 1,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        TextSpan(
          text: result,
          style: TextStyle(
            height: 1,
            fontSize: result.length >= 15 ? 36 : 48,
            letterSpacing: -8,
            color: Colors.grey[700],
            fontFamily: "LetteraMono",
          ),
        ),
      ),
    );
  }
}
