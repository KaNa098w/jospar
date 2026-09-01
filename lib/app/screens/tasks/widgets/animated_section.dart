import 'package:flutter/material.dart';

class AnimatedSection extends StatelessWidget {
  final Widget child;
  final bool hidden;

  const AnimatedSection({super.key, required this.child, required this.hidden});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: hidden ? 0.4 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        offset: hidden ? const Offset(0, -0.02) : Offset.zero,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
