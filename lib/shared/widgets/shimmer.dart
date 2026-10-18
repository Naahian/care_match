import 'package:flutter/material.dart';

/// Theme-aware loading animation that respects the system's motion setting.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child, required this.semanticLabel});

  final Widget child;
  final String semanticLabel;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) => ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment(-3 + 6 * _controller.value, 0),
                end: Alignment(-1 + 6 * _controller.value, 0),
                colors: [
                  scheme.surfaceContainerHighest,
                  scheme.surfaceContainerLow,
                  scheme.surfaceContainerHighest,
                ],
              ).createShader(bounds),
              child: child,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
