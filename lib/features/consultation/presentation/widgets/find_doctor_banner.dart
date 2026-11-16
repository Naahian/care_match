import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Bottom call-to-action banner prompting the user to find a doctor to chat
/// or video consult with.
class FindDoctorBanner extends StatelessWidget {
  const FindDoctorBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: AppRadius.card,
                  ),
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Find a doctor to\nchat or video',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Get matched with the right specialist',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.card,
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Find a doctor'),
            ),
          ],
        ),
      ),
    );
  }
}
