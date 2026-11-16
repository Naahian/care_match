import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

/// Shared CareMatch logo and wordmark.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      final theme = Theme.of(context);
      final scheme = theme.colorScheme;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: AppRadius.button,
            ),
            child: Icon(Icons.add, color: scheme.onPrimary),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'CareMatch',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }
    return Image.asset(
      'assets/images/carematch_logo.png',
      width: 192,
      height: 64,
      fit: BoxFit.contain,
      semanticLabel: AppConstants.appName,
    );
  }
}
