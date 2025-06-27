import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.color,
    required this.drawablePath,
    this.width,
  });

  final Color color;
  final String drawablePath;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20),
      child: Material(
        child: Ink(
          width: width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.vibrate();
            },
            child: Center(child: SvgPicture.asset(drawablePath)),
          ),
        ),
      ),
    );
  }
}
