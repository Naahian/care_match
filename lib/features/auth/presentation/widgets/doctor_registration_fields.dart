import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../domain/entities/doctor_registration_details.dart';
import 'auth_text_field.dart';

/// Owns only form resources; registration is submitted by the auth controller.
class DoctorRegistrationFields extends StatefulWidget {
  const DoctorRegistrationFields({super.key, required this.enabled});
  final bool enabled;

  @override
  State<DoctorRegistrationFields> createState() =>
      DoctorRegistrationFieldsState();
}

class DoctorRegistrationFieldsState extends State<DoctorRegistrationFields> {
  final _phone = TextEditingController();
  final _specialties = TextEditingController();
  final _degrees = TextEditingController();
  final _clinics = [_ClinicFields()];
  final _times = [_TimeFields()];
  final _days = <String>{};
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  DoctorRegistrationDetails get value => DoctorRegistrationDetails(
    phone: _phone.text.trim(),
    clinics: [
      for (final clinic in _clinics)
        DoctorClinic(
          name: clinic.name.text.trim(),
          location: clinic.location.text.trim(),
        ),
    ],
    specialties: _split(_specialties.text),
    degrees: _split(_degrees.text),
    timeAvailable: [
      for (final time in _times)
        DoctorTimeRange(start: _apiTime(time.start!), end: _apiTime(time.end!)),
    ],
    daysAvailable: _weekdays.where(_days.contains).toList(),
  );

  static List<String> _split(String text) => text
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toSet()
      .toList();
  static String _apiTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
  static String? _requiredList(String? value) =>
      _split(value ?? '').isEmpty ? 'Enter at least one item.' : null;

  @override
  void dispose() {
    _phone.dispose();
    _specialties.dispose();
    _degrees.dispose();
    for (final clinic in _clinics) {
      clinic.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: AppSpacing.md),
      AuthTextField(
        controller: _phone,
        enabled: widget.enabled,
        label: 'Phone number',
        hint: '+8801700000000',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        validator: _required,
      ),
      const SizedBox(height: AppSpacing.md),
      AuthTextField(
        controller: _specialties,
        enabled: widget.enabled,
        label: 'Specialties',
        hint: 'e.g. Cardiology, Internal medicine',
        icon: Icons.medical_services_outlined,
        validator: _requiredList,
      ),
      const SizedBox(height: AppSpacing.sm),
      const Text('Separate specialties and degrees with commas.'),
      const SizedBox(height: AppSpacing.md),
      AuthTextField(
        controller: _degrees,
        enabled: widget.enabled,
        label: 'Degrees',
        hint: 'e.g. MBBS, MD',
        icon: Icons.school_outlined,
        validator: _requiredList,
      ),
      const SizedBox(height: AppSpacing.lg),
      Text('Clinics', style: Theme.of(context).textTheme.titleMedium),
      for (var index = 0; index < _clinics.length; index++)
        _clinic(context, index),
      TextButton.icon(
        onPressed: widget.enabled
            ? () => setState(() => _clinics.add(_ClinicFields()))
            : null,
        icon: const Icon(Icons.add),
        label: const Text('Add clinic'),
      ),
      const SizedBox(height: AppSpacing.md),
      Text('Available hours', style: Theme.of(context).textTheme.titleMedium),
      for (var index = 0; index < _times.length; index++) _time(context, index),
      TextButton.icon(
        onPressed: widget.enabled
            ? () => setState(() => _times.add(_TimeFields()))
            : null,
        icon: const Icon(Icons.add),
        label: const Text('Add time range'),
      ),
      const SizedBox(height: AppSpacing.md),
      _daysField(context),
    ],
  );

  Widget _clinic(BuildContext context, int index) {
    final clinic = _clinics[index];
    return Column(
      key: ObjectKey(clinic),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: clinic.name,
          enabled: widget.enabled,
          label: 'Clinic ${index + 1} name',
          hint: 'Clinic name',
          icon: Icons.local_hospital_outlined,
          validator: _required,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          controller: clinic.location,
          enabled: widget.enabled,
          label: 'Clinic ${index + 1} location',
          hint: 'Address or location',
          icon: Icons.location_on_outlined,
          validator: _required,
        ),
        if (_clinics.length > 1)
          TextButton(
            onPressed: widget.enabled
                ? () {
                    setState(() => _clinics.remove(clinic));
                    // Dispose after the removed text fields have left the tree.
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => clinic.dispose(),
                    );
                  }
                : null,
            child: Text('Remove clinic ${index + 1}'),
          ),
      ],
    );
  }

  Widget _time(BuildContext context, int index) {
    final time = _times[index];
    return FormField<bool>(
      key: ObjectKey(time),
      validator: (_) {
        if (time.start == null || time.end == null) {
          return 'Select a start and end time.';
        }
        if (time.end!.hour * 60 + time.end!.minute <=
            time.start!.hour * 60 + time.start!.minute) {
          return 'End time must be after start time.';
        }
        return null;
      },
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final start in [true, false])
                OutlinedButton(
                  onPressed: widget.enabled
                      ? () async {
                          final selected = await showTimePicker(
                            context: context,
                            initialTime:
                                (start ? time.start : time.end) ??
                                const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (!mounted || selected == null) return;
                          setState(() {
                            if (start) {
                              time.start = selected;
                            } else {
                              time.end = selected;
                            }
                          });
                          field.didChange(true);
                        }
                      : null,
                  child: Text(
                    '${start ? 'Start' : 'End'} ${index + 1}: ${(start ? time.start : time.end)?.format(context) ?? 'Select time'}',
                  ),
                ),
              if (_times.length > 1)
                IconButton(
                  tooltip: 'Remove time range ${index + 1}',
                  onPressed: widget.enabled
                      ? () => setState(() => _times.remove(time))
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
            ],
          ),
          if (field.hasError)
            Text(
              field.errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    );
  }

  Widget _daysField(BuildContext context) => FormField<bool>(
    validator: (_) =>
        _days.isEmpty ? 'Select at least one available day.' : null,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Available days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final day in _weekdays)
              FilterChip(
                label: Text(day),
                selected: _days.contains(day),
                onSelected: widget.enabled
                    ? (selected) {
                        setState(() {
                          if (selected) {
                            _days.add(day);
                          } else {
                            _days.remove(day);
                          }
                        });
                        field.didChange(true);
                      }
                    : null,
              ),
          ],
        ),
        if (field.hasError)
          Text(
            field.errorText!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
  );
}

class _ClinicFields {
  final name = TextEditingController();
  final location = TextEditingController();
  void dispose() {
    name.dispose();
    location.dispose();
  }
}

class _TimeFields {
  TimeOfDay? start;
  TimeOfDay? end;
}
