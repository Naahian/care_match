import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/theme/theme.dart';
import 'package:flutter/material.dart';

import 'illustration_slot.dart';
import 'quick_action.dart';
import 'scrollable_fill.dart';

/// Page 4: illustration on top, centered text, quick-action shortcuts.
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
            const Expanded(
              flex: 4,
              child: IllustrationSlot(
                imageAsset: 'assets/images/welcome_4.png',
              ),
            ),
            Text(
              'Better care starts here',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: QuickAction(
                    icon: Icons.medical_services_outlined,
                    label: 'Find a Doctor',
                    background: scheme.primaryContainer,
                    foreground: scheme.primary,
                  ),
                ),
                Expanded(
                  child: QuickAction(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat Consult',
                    background: scheme.secondaryContainer,
                    foreground: scheme.onSecondaryContainer,
                  ),
                ),
                Expanded(
                  child: QuickAction(
                    icon: Icons.videocam_outlined,
                    label: 'Video Consult',
                    background: scheme.tertiaryContainer,
                    foreground: scheme.onTertiaryContainer,
                  ),
                ),
                Expanded(
                  child: QuickAction(
                    icon: Icons.description_outlined,
                    label: 'My Care',
                    background: extras.warningContainer,
                    foreground: extras.warning,
                  ),
                ),
              ],
            ),
            Expanded(flex: 1, child: const SizedBox(height: AppSpacing.lg)),
          ],
        ),
      ),
    );
  }
}
