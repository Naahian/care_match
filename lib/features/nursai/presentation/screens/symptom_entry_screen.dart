import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/symptom_intake.dart';
import '../widgets/symptom_question_card.dart';
import '../widgets/symptom_flow_header.dart';

class SymptomEntryScreen extends StatefulWidget {
  const SymptomEntryScreen({super.key, this.initialSymptoms = ''});
  final String initialSymptoms;
  @override
  State<SymptomEntryScreen> createState() => _SymptomEntryScreenState();
}

class _SymptomEntryScreenState extends State<SymptomEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _symptoms = TextEditingController(text: widget.initialSymptoms);
  final _age = TextEditingController();
  final _location = TextEditingController();
  final _durationDays = TextEditingController();
  final _medicalHistory = TextEditingController();
  final _currentMedications = TextEditingController();
  @override
  void dispose() {
    _symptoms.dispose();
    _age.dispose();
    _location.dispose();
    _durationDays.dispose();
    _medicalHistory.dispose();
    _currentMedications.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.pushNamed(
      AppRoutes.symptomAssessment,
      extra: SymptomIntake(
        symptoms: _symptoms.text.trim(),
        age: int.parse(_age.text.trim()),
        durationDays: int.parse(_durationDays.text.trim()),
        medicalHistory: _medicalHistory.text.trim(),
        currentMedications: _currentMedications.text
            .split(RegExp(r'[\n,]'))
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(),
        location: _location.text.trim(),
      ),
    );
  }

  Widget _ageField() => TextFormField(
    controller: _age,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(3),
    ],
    validator: (value) {
      final age = int.tryParse(value ?? '');
      return age == null || age < 0 || age > 130
          ? 'Enter an age between 0 and 130.'
          : null;
    },
    decoration: const InputDecoration(
      labelText: 'Age',
      hintText: 'Your age in years',
    ),
  );

  Widget _durationField() => TextFormField(
    controller: _durationDays,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ],
    validator: (value) {
      final days = int.tryParse(value ?? '');
      return days == null || days < 0 || days > 3650
          ? 'Enter a duration between 0 and 3650 days.'
          : null;
    },
    decoration: const InputDecoration(
      labelText: 'Duration in days',
      hintText: 'How many days have you had symptoms?',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                SymptomFlowHeader(
                  title: 'Symptom check',
                  currentStep: 1,
                  onBack: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                'How are you\nfeeling today?',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.smart_toy_rounded,
                                color: theme.colorScheme.onPrimary,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Describe your symptoms in your own\nwords and our AI will guide you.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SymptomQuestionCard(
                          step: '01',
                          title: "Tell us what’s bothering you",
                          icon: Icons.edit_note_rounded,
                          child: TextFormField(
                            controller: _symptoms,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 4000,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Describe your symptoms.'
                                : null,
                            decoration: const InputDecoration(
                              hintText: 'Describe what you are experiencing…',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SymptomQuestionCard(
                          step: '02',
                          title: 'Age and duration',
                          icon: Icons.person_outline_rounded,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 300) {
                                return Column(
                                  children: [
                                    _ageField(),
                                    const SizedBox(height: AppSpacing.sm),
                                    _durationField(),
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _ageField()),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: _durationField()),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 2,
                            top: AppSpacing.xs,
                          ),
                          child: Text(
                            'Enter 0 for less than a day.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SymptomQuestionCard(
                          step: '03',
                          title: 'Location',
                          icon: Icons.location_on_outlined,
                          child: TextFormField(
                            controller: _location,
                            maxLength: 200,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter your city or area.'
                                : null,
                            decoration: const InputDecoration(
                              hintText: 'Your city or area',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SymptomQuestionCard(
                          step: 'Optional',
                          title: 'Medical history',
                          icon: Icons.medical_information_outlined,
                          child: TextFormField(
                            controller: _medicalHistory,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 2000,
                            decoration: const InputDecoration(
                              labelText: 'Medical history (optional)',
                              hintText: 'Previous conditions, or none',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SymptomQuestionCard(
                          step: 'Optional',
                          title: 'Current medications',
                          icon: Icons.medication_outlined,
                          child: TextFormField(
                            controller: _currentMedications,
                            minLines: 2,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Current medications (optional)',
                              hintText: 'Medication names, or none',
                              helperText:
                                  'Enter one medication per line or separate with commas.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _continue,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.card,
                        ),
                      ),
                      child: Row(
                        children: const [
                          Expanded(child: Text('Continue')),
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
