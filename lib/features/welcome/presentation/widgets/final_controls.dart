import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'page_dots.dart';

/// Last-page dots, primary action and login link.
class FinalControls extends StatelessWidget {
  const FinalControls({
    super.key,
    required this.index,
    required this.count,
    required this.onGetStarted,
    required this.onLogin,
  });

  final int index;
  final int count;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PageDots(index: index, count: count),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onGetStarted,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 56),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: Text('Get started', textAlign: TextAlign.center),
                ),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Already have an account?', style: theme.textTheme.bodySmall),
            TextButton(
              onPressed: onLogin,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                'Log in',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
