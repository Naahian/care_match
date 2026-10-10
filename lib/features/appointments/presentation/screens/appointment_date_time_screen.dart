import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_doctor_card.dart';
import '../widgets/appointment_time_slots.dart';

class AppointmentDateTimeScreen extends StatefulWidget {
  const AppointmentDateTimeScreen({super.key, required this.draft});
  final AppointmentDraft draft;
  @override
  State<AppointmentDateTimeScreen> createState() =>
      _AppointmentDateTimeScreenState();
}

class _AppointmentDateTimeScreenState extends State<AppointmentDateTimeScreen> {
  final _today = DateUtils.dateOnly(DateTime.now());
  @override
  void initState() {
    super.initState();
    widget.draft.date ??= _today.add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Select date & time'), centerTitle: true),
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
                    AppointmentDoctorCard(draft: widget.draft),
                    const SizedBox(height: AppSpacing.md),
                    Card(
                      child: CalendarDatePicker(
                        initialDate: widget.draft.date!,
                        firstDate: _today,
                        lastDate: DateTime(
                          _today.year + 1,
                          _today.month,
                          _today.day,
                        ),
                        onDateChanged: (date) => setState(() {
                          widget.draft.date = date;
                          widget.draft.time = null;
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Available time slots',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Local timezone: ${DateTime.now().timeZoneName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // TODO: load actual available slots for the doctor and consultation type.
                    AppointmentTimeSlots(
                      date: widget.draft.date!,
                      selected: widget.draft.time,
                      onSelected: (time) =>
                          setState(() => widget.draft.time = time),
                    ),
                  ],
                ),
              ),
              AppointmentContinueButton(
                label: 'Continue to payment',
                onPressed:
                    widget.draft.scheduledAt?.isAfter(DateTime.now()) == true
                    ? () {
                        context.pushNamed(
                          AppRoutes.appointmentPayment,
                          pathParameters: {
                            'doctorId': doctorProfileId(
                              widget.draft.doctor.summary.name,
                            ),
                          },
                          extra: widget.draft,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
