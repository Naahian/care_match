import 'dart:math' as math;

import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'floating_overlay.dart';

/// Scales the artwork and conversation together to keep the bubbles aligned.
class ConsultationIllustration extends StatelessWidget {
  const ConsultationIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 240),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 360,
          height: 360,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                width: 360,
                height: 270,
                child: Image.asset(
                  'assets/images/welcome_1.png',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
              const Positioned(
                top: 224,
                left: 80,
                width: 240,
                child: FloatingOverlay(
                  child: _ChatBubble(
                    message: 'How are you feeling today?\nAny improvement?',
                  ),
                ),
              ),
              const Positioned(
                top: 304,
                right: 16,
                width: 250,
                child: FloatingOverlay(
                  phase: math.pi,
                  child: _ChatBubble(
                    message: 'I’m feeling better, thank you!',
                    isReply: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, this.isReply = false});

  final String message;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = isReply ? scheme.secondaryContainer : scheme.surface;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: isReply ? null : 16,
          right: isReply ? 16 : null,
          bottom: -4,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: SizedBox(
              width: 14,
              height: 14,
              child: ColoredBox(color: background),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: isReply
                ? AppRadius.card
                : const BorderRadius.all(Radius.circular(AppRadius.xl)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.1),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isReply
                  ? scheme.onSecondaryContainer
                  : scheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
