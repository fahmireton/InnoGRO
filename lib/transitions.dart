import 'package:flutter/material.dart';

Route<T> slideRoute<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 300),
  reverseTransitionDuration: const Duration(milliseconds: 250),
  transitionsBuilder: (_, anim, secondAnim, child) {
    final slide = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
      .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
    final fade = Tween(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: anim, curve: const Interval(0.0, 0.5)));
    return SlideTransition(position: slide,
      child: FadeTransition(opacity: fade, child: child));
  },
);
