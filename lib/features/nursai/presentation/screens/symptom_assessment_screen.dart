import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/nursai_controller.dart';
import '../widgets/triage_result_card.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../models/symptom_intake.dart';
import '../widgets/assessment_status_card.dart';

class SymptomAssessmentScreen extends ConsumerStatefulWidget {
  const SymptomAssessmentScreen({super.key, required this.intake});
  final SymptomIntake intake;
  @override
  ConsumerState<SymptomAssessmentScreen> createState() =>
      _SymptomAssessmentScreenState();
}

class _SymptomAssessmentScreenState
    extends ConsumerState<SymptomAssessmentScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(
          ref.read(nursaiControllerProvider.notifier).assess(widget.intake),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(nursaiControllerProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: AppSpacing.page,
              children: [
                Image.asset(
                  'assets/images/ai_assessment.png',
                  height: 26.h.clamp(140.0, 260.0),
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
                Text(
                  state.assessment != null
                      ? 'Your symptom assessment'
                      : state.errorMessage != null
                      ? 'Assessment unavailable'
                      : 'Assessing your symptoms',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'NurseAI reviews your details to suggest the next steps for care.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.isLoading) const AssessmentStatusCard(activeStage: 0),
                if (state.errorMessage != null) ...[
                  Text(state.errorMessage!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () => ref
                        .read(nursaiControllerProvider.notifier)
                        .assess(widget.intake),
                    child: const Text('Retry'),
                  ),
                ],
                if (state.assessment case final assessment?) ...[
                  TriageResultCard(assessment: assessment),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => context.pushNamed(
                      AppRoutes.recommendedDoctors,
                      extra: assessment,
                    ),
                    child: Text(
                      assessment.recommendedSpecialties.isEmpty
                          ? 'Browse doctors'
                          : 'Browse recommended specialties',
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Expanded(
                          child: Text(
                            'AI guidance is not a diagnosis. Consult a qualified healthcare professional for medical advice.',
                          ),
                        ),
                      ],
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
