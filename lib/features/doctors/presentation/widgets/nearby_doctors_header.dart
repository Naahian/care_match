import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Sample location label. Replace with the user's resolved location.
const String sampleLocation = 'Dhaka, Bangladesh';

/// Section header for nearby doctors: title, location pill and "See all".
class NearbyDoctorsHeader extends StatelessWidget {
  const NearbyDoctorsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby Doctors',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: () {
                  // TODO: open the location picker to change the search area
                },
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.sp,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(sampleLocation, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: navigate to the full nearby doctors list
          },
          child: Text(
            'See all',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
