import '../../../doctors/presentation/widgets/doctor_profile.dart';
import '../../../doctors/domain/entities/doctor.dart' as directory;
import '../../../doctors/presentation/ui_models/doctor_presentation.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

import 'package:care_match/shared/widgets/doctor_card.dart';
import 'package:care_match/shared/widgets/empty_state.dart';
import 'doctor_summary.dart';
import '../controllers/home_state.dart';
import 'doctor_card_shimmer.dart';
import 'doctors_load_error.dart';

/// Section header ("Featured Doctors" + See all) followed by [DoctorCard]s.
class FeaturedDoctorsSection extends StatelessWidget {
  const FeaturedDoctorsSection({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final HomeState state;
  final VoidCallback onRetry;

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
                'Featured doctors',
                style: theme.textTheme.titleLarge?.copyWith(
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
                  color: scheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (state.isLoading)
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            const DoctorCardShimmer(),
          ],
        if (state.errorMessage != null) ...[
          DoctorsLoadError(message: state.errorMessage!, onRetry: onRetry),
          const SizedBox(height: AppSpacing.md),
        ],
        if (!state.isLoading &&
            state.errorMessage == null &&
            state.doctors.isEmpty)
          const EmptyState(
            icon: Icons.people_outline_rounded,
            message: 'No verified doctors found.',
          ),
        for (var i = 0; !state.isLoading && i < state.doctors.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          DoctorCard(
            doctor: _summary(i),
            featured: true,
            highlightAlt: state.doctors[i].specialties.any(
              (name) => name.toLowerCase() == 'dermatology',
            ),
            onTap: () {
              context.pushNamed(
                AppRoutes.doctorDetail,
                pathParameters: {'doctorId': state.doctors[i].id},
                extra: _profile(i),
              );
            },
          ),
        ],
      ],
    );
  }

  directory.Doctor _doctor(int index) {
    final doctor = state.doctors[index];
    return directory.Doctor(
      id: doctor.id,
      name: doctor.name,
      photoUrl: doctor.photoUrl,
      specialties: doctor.specialties,
      degrees: doctor.degrees,
      daysAvailable: doctor.daysAvailable,
      timeAvailable: doctor.timeAvailable
          .map((t) => directory.DoctorTimeRange(start: t.start, end: t.end))
          .toList(),
      clinics: doctor.clinics
          .map(
            (c) => directory.DoctorClinic(name: c.name, location: c.location),
          )
          .toList(),
      verified: doctor.verified,
    );
  }

  DoctorSummary _summary(int index) => _doctor(index).summary;
  DoctorProfile _profile(int index) => _doctor(index).profile;
}
