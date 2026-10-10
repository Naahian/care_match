import 'dart:async';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../models/symptom_intake.dart';
import '../widgets/assessment_status_card.dart';

class SymptomAssessmentScreen extends StatefulWidget {
  const SymptomAssessmentScreen({super.key, required this.intake});
  final SymptomIntake intake;
  @override
  State<SymptomAssessmentScreen> createState() =>
      _SymptomAssessmentScreenState();
}

class _SymptomAssessmentScreenState extends State<SymptomAssessmentScreen> {
  Timer? _timer;
  int _activeStage = 0;
  @override
  void initState() {
    super.initState();
    // TODO: replace this demo timer with actual AI assessment state and results.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeStage == 2) {
        timer.cancel();
        if (mounted) {
          context.pushReplacementNamed(
            AppRoutes.recommendedDoctors,
            extra: widget.intake,
          );
        }
      } else {
        setState(() => _activeStage++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  'Assessing your symptoms',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Preparing a preview of your symptom assessment and recommended doctors.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AssessmentStatusCard(activeStage: _activeStage),
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
                            'AI guidance is not a diagnosis. This preview uses sample matches until the assessment service is connected.',
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
