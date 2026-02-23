import "package:flutter/material.dart";

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;
  final Curve curve;
  final Duration duration;

  SlidePageRoute({
    required this.page,
    this.curve = Curves.ease,
    this.beginOffset = const Offset(1, 0),
    this.duration = const Duration(milliseconds: 200),
  }) : super(
         transitionDuration: duration,
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final tween = Tween(
             begin: beginOffset,
             end: Offset.zero,
           ).chain(CurveTween(curve: curve));

           final slideIn = animation.drive(tween);
           final slideOut = Tween(
             begin: Offset.zero,
             end: -beginOffset,
           ).chain(CurveTween(curve: curve)).animate(secondaryAnimation);

           return SlideTransition(
             position: slideIn,
             child: SlideTransition(position: slideOut, child: child),
           );
         },
       );
}
