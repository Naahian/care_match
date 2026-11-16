import 'dart:async';

import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/features/doctors/domain/entities/doctor.dart';
import 'package:care_match/features/doctors/domain/utils/specialty_matching.dart';
import 'package:care_match/features/doctors/presentation/controllers/doctors_controller.dart';
import 'package:care_match/features/doctors/presentation/ui_models/doctor_presentation.dart';
import 'package:care_match/features/nursai/domain/entities/triage_assessment.dart';
import 'package:care_match/features/nursai/presentation/models/symptom_intake.dart';
import 'package:care_match/shared/widgets/doctor_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      if (mounted) {
        unawaited(
          ref.read(doctorsControllerProvider.notifier).load(refresh: true),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorsControllerProvider);
    final specialties =
        widget.assessment?.recommendedSpecialties ?? const <String>[];
    final matches = specialties.isEmpty
        ? state.doctors
        : state.doctors
              .where(
                (doctor) => doctor.specialties.any(
                  (specialty) => specialties.any(
                    (recommended) =>
                        matchesRecommendedSpecialty(recommended, specialty),
                  ),
                ),
              )
              .toList();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _RecommendedHeader(
                  onBack: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref
                        .read(doctorsControllerProvider.notifier)
                        .load(refresh: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      children: [
                        Text(
                          specialties.isEmpty
                              ? 'Browse doctors'
                              : 'Recommended\nspecialties',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SpecialtySummary(specialties: specialties),
                        const SizedBox(height: 26),
                        LayoutBuilder(
                          builder: (context, constraints) =>
                              constraints.maxWidth < 320
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Doctors for you',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${matches.length} ${matches.length == 1 ? 'doctor' : 'doctors'}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Doctors for you',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      '${matches.length} ${matches.length == 1 ? 'doctor' : 'doctors'}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (state.isLoading ||
                            (!state.hasLoaded && state.errorMessage == null))
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (state.errorMessage != null)
                          _LoadFailure(
                            message: state.errorMessage!,
                            onRetry: () => ref
                                .read(doctorsControllerProvider.notifier)
                                .load(refresh: true),
                          )
                        else if (matches.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            child: Text(
                              'No matching doctors are available right now.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          for (final doctor in matches) ...[
                            _RecommendedDoctorCard(
                              doctor: doctor,
                              onTap: () => context.pushNamed(
                                AppRoutes.doctorDetail,
                                pathParameters: {'doctorId': doctor.id},
                                extra: doctor.profile,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.pushNamed(AppRoutes.doctors),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.card,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(child: Text('See all doctors')),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
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

class _RecommendedHeader extends StatelessWidget {
  const _RecommendedHeader({required this.onBack});
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          IconButton.filled(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: colors.surface,
              foregroundColor: colors.onSurface,
              fixedSize: const Size(42, 42),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Recommended care',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtySummary extends StatelessWidget {
  const _SpecialtySummary({required this.specialties});
  final List<String> specialties;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayed = specialties.isEmpty
        ? const ['All specialties']
        : specialties;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: AppRadius.sheet,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: AppRadius.input,
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctors listed under',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your recommended specialties',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final specialty in displayed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: AppRadius.input,
                  ),
                  child: Text(specialty, style: theme.textTheme.labelMedium),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedDoctorCard extends StatelessWidget {
  const _RecommendedDoctorCard({required this.doctor, required this.onTap});
  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availability = doctor.daysAvailable.isEmpty
        ? const ['Availability not provided']
        : doctor.daysAvailable;
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.sheet,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DoctorAvatar(
                    doctorName: doctor.name ?? 'Doctor',
                    photoUrl: doctor.photoUrl,
                    radius: 26,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name ?? 'Name not provided',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          doctor.specialties.isEmpty
                              ? 'Specialty not provided'
                              : doctor.specialties.join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('AVAILABILITY', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final day in availability)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: AppRadius.input,
                      ),
                      child: Text(
                        day,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(message, textAlign: TextAlign.center),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ],
  );
}
