import 'dart:math' as math;

import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'floating_overlay.dart';

/// Keeps the floating overlays aligned with the artwork at every screen size.
class SymptomIllustration extends StatelessWidget {
  const SymptomIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 240),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 360,
          height: 320,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                width: 340,
                height: 290,
                child: Image.asset(
                  'assets/images/welcome_2.png',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
              Positioned(
                top: 14,
                right: 34,
                width: 148,
                child: FloatingOverlay(
                  child: const _SpeechBubble(
                    child: Text('I have a sore throat\nand mild fever.'),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                right: 42,
                width: 76,
                child: FloatingOverlay(
                  phase: math.pi / 2,
                  child: _SpeechBubble(
                    child: Icon(
                      Icons.smart_toy_rounded,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                      semanticLabel: 'AI symptom assistant',
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 36,
                width: 188,
                child: FloatingOverlay(
                  phase: math.pi,
                  child: const _RecommendedDoctorCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 18,
          bottom: -5,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: SizedBox(
              width: 16,
              height: 16,
              child: ColoredBox(color: scheme.surface),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppRadius.card,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.1),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: DefaultTextStyle(
              style: theme.textTheme.bodySmall!.copyWith(
                color: scheme.onPrimaryContainer,
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedDoctorCard extends StatelessWidget {
  const _RecommendedDoctorCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: scheme.secondaryContainer,
            child: ClipOval(
              child: Image.asset(
                'assets/images/male_doctor_avatar.png',
                width: 46,
                height: 46,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('General Medicine', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
