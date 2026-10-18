import 'dart:math' as math;

import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Gentle floating motion and a mouse-hover lift for onboarding overlays.
class FloatingOverlay extends StatefulWidget {
  const FloatingOverlay({super.key, required this.child, this.phase = 0});

  final Widget child;
  final double phase;

  @override
  State<FloatingOverlay> createState() => _FloatingOverlayState();
}

class _FloatingOverlayState extends State<FloatingOverlay>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _float.stop();
      _float.value = 0;
    } else if (!_float.isAnimating) {
      _float.repeat();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered && !reduceMotion
            ? const Offset(0, -0.06)
            : Offset.zero,
        duration: reduceMotion ? Duration.zero : AppConstants.animationDuration,
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _hovered && !reduceMotion ? 1.03 : 1,
          duration: reduceMotion
              ? Duration.zero
              : AppConstants.animationDuration,
          curve: Curves.easeOut,
          child: AnimatedBuilder(
            animation: _float,
            child: widget.child,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                0,
                reduceMotion
                    ? 0
                    : math.sin(_float.value * math.pi * 2 + widget.phase) * 5,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
