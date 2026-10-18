import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/doctor_card.dart';
import '../../../../shared/widgets/doctor_card_shimmer.dart';
import '../controllers/doctors_state.dart';
import '../ui_models/doctor_presentation.dart';

class DoctorsResults extends StatelessWidget {
  const DoctorsResults({super.key, required this.state, required this.onRetry});
  final DoctorsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading || (!state.hasLoaded && state.errorMessage == null)) {
      return Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            const DoctorCardShimmer(),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }
    final doctors = state.visibleDoctors;
    return Column(
      children: [
        if (state.errorMessage != null) ...[
          Text(state.errorMessage!),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
        if (state.hasLoaded && doctors.isEmpty)
          const Text('No doctors found. Try another search or specialty.'),
        for (final doctor in doctors) ...[
          DoctorCard(
            doctor: doctor.summary,
            highlightAlt: false,
            onTap: () => context.pushNamed(
              AppRoutes.doctorDetail,
              pathParameters: {'doctorId': doctor.id},
              extra: doctor.profile,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
