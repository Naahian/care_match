import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../widgets/profile_selection_tile.dart';

class SetUpProfileScreen extends StatefulWidget {
  final bool isEditProfile;

  const SetUpProfileScreen({super.key, this.isEditProfile = true});

  @override
  State<SetUpProfileScreen> createState() => _SetUpProfileScreenState();
}

class _SetUpProfileScreenState extends State<SetUpProfileScreen> {
  DateTime? _birthDate;
  String? _gender;
  String? _bloodGroup;
  String _language = 'English';

  Future<void> _pickBirthDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (date != null && mounted) setState(() => _birthDate = date);
  }

  Future<String?> _pickOption(
    String title,
    List<String> options,
    String? current,
  ) => showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.6,
      child: Column(
        children: [
          Padding(
            padding: AppSpacing.card,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: ListView(
              children: options
                  .map(
                    (option) => ListTile(
                      title: Text(option),
                      trailing: option == current
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: AppSpacing.page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headingTexts(
                  theme: Theme.of(context),
                  title: 'Set up your profile',
                  subtitle:
                      'Complete your details to personalize\nyour care experience.',
                ),
                // TODO: add the profile photo/avatar and upload control.
                SizedBox(height: 16.h.clamp(100.0, 160.0)),
                ProfileSelectionTile(
                  label: 'Date of birth',
                  value: _birthDate == null
                      ? 'Select your date of birth'
                      : MaterialLocalizations.of(
                          context,
                        ).formatMediumDate(_birthDate!),
                  icon: Icons.calendar_month_outlined,
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: AppSpacing.sm),
                ProfileSelectionTile(
                  label: 'Gender',
                  value: _gender ?? 'Select your gender',
                  icon: Icons.person_outline_rounded,
                  onTap: () async {
                    final value = await _pickOption('Gender', [
                      'Female',
                      'Male',
                      'Non-binary',
                      'Prefer not to say',
                    ], _gender);
                    if (value != null && mounted) {
                      setState(() => _gender = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ProfileSelectionTile(
                  label: 'Blood group',
                  value: _bloodGroup ?? 'Select your blood group',
                  icon: Icons.water_drop_outlined,
                  onTap: () async {
                    final value = await _pickOption('Blood group', [
                      'A+',
                      'A−',
                      'B+',
                      'B−',
                      'AB+',
                      'AB−',
                      'O+',
                      'O−',
                      'Unknown',
                    ], _bloodGroup);
                    if (value != null && mounted) {
                      setState(() => _bloodGroup = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ProfileSelectionTile(
                  label: 'Preferred language',
                  value: _language,
                  icon: Icons.language_rounded,
                  onTap: () async {
                    final value = await _pickOption('Preferred language', [
                      'English',
                      'বাংলা',
                    ], _language);
                    if (value != null && mounted) {
                      setState(() => _language = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  child: Text(
                    widget.isEditProfile ? 'Save Edits' : 'Save and continue',
                  ),
                  onPressed: () {
                    // TODO: persist the profile before navigating.
                    context.goNamed(AppRoutes.home);
                  },
                ),
                SizedBox(height: AppSpacing.sm),
                if (!widget.isEditProfile)
                  TextButton(
                    onPressed: () {
                      context.goNamed(AppRoutes.home);
                    },
                    child: const Text('Skip for now'),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Column headingTexts({
    required ThemeData theme,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
