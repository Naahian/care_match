import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../models/symptom_intake.dart';
import '../widgets/symptom_question_card.dart';

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
  String? _duration;
  BreathingDifficulty? _breathing;
  bool _showBreathingError = false;
  @override
  void dispose() {
    _symptoms.dispose();
    _age.dispose();
    _location.dispose();
    super.dispose();
  }

  void _continue() {
    final valid = _formKey.currentState!.validate();
    setState(() => _showBreathingError = _breathing == null);
    if (!valid || _breathing == null) return;
    FocusScope.of(context).unfocus();
    context.pushNamed(
      AppRoutes.symptomAssessment,
      extra: SymptomIntake(
        symptoms: _symptoms.text.trim(),
        age: int.parse(_age.text.trim()),
        duration: _duration!,
        location: _location.text.trim(),
        breathingDifficulty: _breathing!,
      ),
    );
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
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: AppSpacing.page,
                      children: [
                        Text(
                          'How are you feeling today?',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Describe your symptoms in your own words and our AI will guide you.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Image.asset(
                          'assets/images/symptom_check.png',
                          height: 15.h.clamp(80.0, 160.0),
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                        SymptomQuestionCard(
                          title: "Tell us what’s bothering you",
                          icon: Icons.edit_note_rounded,
                          child: TextFormField(
                            controller: _symptoms,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 500,
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
                          title: 'Age and duration',
                          icon: Icons.person_outline_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _age,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                validator: (value) {
                                  final age = int.tryParse(value ?? '');
                                  return age == null || age < 1 || age > 120
                                      ? 'Enter an age between 1 and 120.'
                                      : null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                  hintText: 'Your age in years',
                                  suffixText: 'years',
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              DropdownButtonFormField<String>(
                                initialValue: _duration,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Duration',
                                  hintText: 'How long have you had symptoms?',
                                ),
                                items:
                                    const [
                                          'Less than a day',
                                          '1–3 days',
                                          '4–7 days',
                                          '1–2 weeks',
                                          'More than 2 weeks',
                                        ]
                                        .map(
                                          (duration) => DropdownMenuItem(
                                            value: duration,
                                            child: Text(duration),
                                          ),
                                        )
                                        .toList(),
                                validator: (value) =>
                                    value == null ? 'Select a duration.' : null,
                                onChanged: (value) =>
                                    setState(() => _duration = value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SymptomQuestionCard(
                          title: 'Location',
                          icon: Icons.location_on_outlined,
                          child: TextFormField(
                            controller: _location,
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
                          title: 'Are you having trouble breathing?',
                          icon: Icons.air_rounded,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  for (final option
                                      in BreathingDifficulty.values)
                                    ChoiceChip(
                                      label: Text(switch (option) {
                                        BreathingDifficulty.no => 'No',
                                        BreathingDifficulty.aLittle =>
                                          'A little',
                                        BreathingDifficulty.yes => 'Yes',
                                      }),
                                      selected: _breathing == option,
                                      onSelected: (_) => setState(() {
                                        _breathing = option;
                                        _showBreathingError = false;
                                      }),
                                    ),
                                ],
                              ),
                              if (_showBreathingError)
                                Text(
                                  'Select an answer.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                            ],
                          ),
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
                      onPressed: _continue,
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.chip,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Continue'),
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
