import 'dart:async';

import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/nursai_controller.dart';
import '../models/symptom_intake.dart';
import '../widgets/assessment_status_card.dart';
import '../widgets/symptom_flow_header.dart';
import '../widgets/triage_result_card.dart';

class SymptomAssessmentScreen extends ConsumerStatefulWidget {
  const SymptomAssessmentScreen({super.key, required this.intake});
  final SymptomIntake intake;

  @override
  ConsumerState<SymptomAssessmentScreen> createState() =>
      _SymptomAssessmentScreenState();
}

class _SymptomAssessmentScreenState
    extends ConsumerState<SymptomAssessmentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _zoomController;
  late final Animation<double> _zoomAnimation;

  void _updateZoom(bool isLoading) {
    if (isLoading && !MediaQuery.disableAnimationsOf(context)) {
      if (!_zoomController.isAnimating) _zoomController.repeat(reverse: true);
    } else {
      _zoomController.reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateZoom(ref.read(nursaiControllerProvider).isLoading);
  }

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _zoomAnimation = _zoomController.drive(
      Tween<double>(
        begin: .94,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeInOut)),
    );
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(
          ref.read(nursaiControllerProvider.notifier).assess(widget.intake),
        );
      }
    });
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(nursaiControllerProvider);
    final isComplete = state.assessment != null;
    ref.listen(nursaiControllerProvider.select((state) => state.isLoading), (
      previous,
      isLoading,
    ) {
      _updateZoom(isLoading);
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                SymptomFlowHeader(
                  title: isComplete ? 'Your assessment' : 'Symptom check',
                  currentStep: isComplete ? 3 : 2,
                  onBack: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    children: [
                      Text(
                        isComplete
                            ? 'NURSEAI · REVIEW COMPLETE'
                            : 'NURSEAI · SYMPTOM REVIEW',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        isComplete
                            ? 'Your symptom\nassessment'
                            : state.errorMessage != null
                            ? 'Assessment\nunavailable'
                            : 'Assessing your\nsymptoms',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'NurseAI reviews your details to suggest\nthe next steps for care.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.isLoading) ...[
                        _AssessmentAnimation(animation: _zoomAnimation),
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: AppRadius.chip,
                            ),
                            child: Text(
                              'Review in progress',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const AssessmentStatusCard(activeStage: 0),
                      ],
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () => ref
                                .read(nursaiControllerProvider.notifier)
                                .assess(widget.intake),
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                      if (state.assessment case final assessment?) ...[
                        TriageResultCard(assessment: assessment),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      const _AiGuidanceNotice(),
                      if (state.isLoading) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Your health, handled with care',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (state.assessment case final assessment?)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.pushNamed(
                          AppRoutes.recommendedDoctors,
                          extra: assessment,
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.card,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                assessment.recommendedSpecialties.isEmpty
                                    ? 'Browse doctors'
                                    : 'Browse recommended specialties',
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded),
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

class _AssessmentAnimation extends StatelessWidget {
  const _AssessmentAnimation({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: ScaleTransition(
        scale: animation,
        child: Container(
          width: 178,
          height: 178,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.primary.withValues(alpha: .25),
              width: 2,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryContainer,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: colors.onPrimary,
                size: 54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiGuidanceNotice extends StatelessWidget {
  const _AiGuidanceNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(child: _GuidanceText()),
        ],
      ),
    );
  }
}

class _GuidanceText extends StatelessWidget {
  const _GuidanceText();

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      children: const [
        TextSpan(
          text: 'AI guidance is not a diagnosis.\n',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text:
              'Consult a qualified healthcare professional for medical advice.',
        ),
      ],
    ),
  );
}
