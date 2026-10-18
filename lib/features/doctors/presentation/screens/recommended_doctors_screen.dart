import 'dart:async';
import '../../../nursai/domain/entities/triage_assessment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/doctors_controller.dart';
import '../widgets/doctors_results.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/features/nursai/presentation/models/symptom_intake.dart';

class RecommendedDoctorsScreen extends ConsumerStatefulWidget {
  const RecommendedDoctorsScreen({super.key, this.intake, this.assessment});
  final SymptomIntake? intake;
  final TriageAssessment? assessment;
  @override
  ConsumerState<RecommendedDoctorsScreen> createState() =>
      _RecommendedDoctorsScreenState();
}

class _RecommendedDoctorsScreenState
    extends ConsumerState<RecommendedDoctorsScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (!mounted) return;
      final controller = ref.read(doctorsControllerProvider.notifier);
      unawaited(controller.load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorsControllerProvider);
    final theme = Theme.of(context);
    final specialties =
        widget.assessment?.recommendedSpecialties ?? const <String>[];
    final matches = specialties.isEmpty
        ? state.doctors
        : state.doctors
              .where(
                (doctor) => doctor.specialties.any(
                  (specialty) => specialties.any(
                    (recommended) =>
                        recommended.toLowerCase() == specialty.toLowerCase(),
                  ),
                ),
              )
              .toList();
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref
                        .read(doctorsControllerProvider.notifier)
                        .load(refresh: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.page,
                      children: [
                        Text(
                          widget.assessment == null
                              ? 'Browse doctors'
                              : 'Recommended specialties',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          specialties.isEmpty
                              ? 'Browse available doctor profiles.'
                              : 'Doctors listed under: ${specialties.join(', ')}.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DoctorsResults(
                          state: state.copyWith(
                            doctors: matches,
                            query: '',
                            specialty: '',
                          ),
                          onRetry: () => ref
                              .read(doctorsControllerProvider.notifier)
                              .load(refresh: true),
                        ),
                      ],
                    ),
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
                      label: const Text('See all doctors'),
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
