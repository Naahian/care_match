import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'package:care_match/shared/widgets/doctor_card.dart';
import 'doctor_summary.dart';

/// Section header ("Featured Doctors" + See all) followed by [DoctorCard]s.
class FeaturedDoctorsSection extends StatelessWidget {
  const FeaturedDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Featured Doctors',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(AppRoutes.doctors);
              },
              child: Text(
                'See all',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < sampleDoctors.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          DoctorCard(
            doctor: sampleDoctors[i],
            highlightAlt: i.isOdd,
            onTap: () {
              context.pushNamed(
                AppRoutes.doctorDetail,
                pathParameters: {
                  'doctorId': doctorProfileId(sampleDoctors[i].name),
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
