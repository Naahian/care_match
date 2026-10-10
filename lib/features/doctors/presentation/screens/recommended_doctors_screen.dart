import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/shared/widgets/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/features/nursai/presentation/models/symptom_intake.dart';
import '../widgets/doctor_profile.dart';
import '../widgets/recommended_doctor_profiles.dart';
import '../widgets/doctor_match_summary.dart';

class RecommendedDoctorsScreen extends StatelessWidget {
  const RecommendedDoctorsScreen({super.key, this.intake});
  final SymptomIntake? intake;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: AppSpacing.page,
                    children: [
                      Text(
                        'Recommended doctors',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sample matches for your care journey.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const DoctorMatchSummary(),
                      const SizedBox(height: AppSpacing.md),
                      for (final profile in sampleRecommendedProfiles) ...[
                        DoctorCard(
                          doctor: profile.summary,
                          highlightAlt: !profile.summary.availableToday,
                          price: profile.chatPrice,
                          onTap: () => context.pushNamed(
                            AppRoutes.doctorDetail,
                            pathParameters: {
                              'doctorId': doctorProfileId(profile.summary.name),
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: AppSpacing.page,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.chip,
                        ),
                      ),
                      onPressed: () => context.pushNamed(AppRoutes.doctors),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('See all matches'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
