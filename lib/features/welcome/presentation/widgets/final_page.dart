import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:flutter/material.dart';

import 'illustration_slot.dart';
import 'quick_action.dart';
import 'scrollable_fill.dart';

/// Final page with centered copy, existing artwork and care feature tiles.
class FinalPage extends StatelessWidget {
  const FinalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final extras = theme.extension<AppExtras>()!;

    return ScrollableFill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Better care\nstarts here',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Describe your symptoms, get matched with the right doctor, '
              'and consult by chat or video, all in one app.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: IllustrationSlot(
                imageAsset: 'assets/images/welcome_4.png',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: QuickAction(
                      icon: Icons.medical_services_outlined,
                      label: 'Find a\ndoctor',
                      background: scheme.primaryContainer,
                      foreground: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat\nconsult',
                      background: scheme.secondaryContainer,
                      foreground: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.videocam_outlined,
                      label: 'Video\nconsult',
                      background: scheme.tertiaryContainer,
                      foreground: scheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.description_outlined,
                      label: 'My\ncare',
                      background: extras.warningContainer,
                      foreground: extras.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
