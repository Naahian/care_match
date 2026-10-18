import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:care_match/features/doctors/domain/entities/doctor_availability.dart';
import 'package:care_match/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_draft.dart';
import '../widgets/appointment_continue_button.dart';
import '../widgets/appointment_doctor_card.dart';
import '../widgets/appointment_time_slots.dart';

class AppointmentDateTimeScreen extends StatefulWidget {
  const AppointmentDateTimeScreen({
    super.key,
    required this.draft,
    this.now = DateTime.now,
  });
  final AppointmentDraft draft;
  final DateTime Function() now;

  @override
  State<AppointmentDateTimeScreen> createState() =>
      _AppointmentDateTimeScreenState();
}

class _AppointmentDateTimeScreenState extends State<AppointmentDateTimeScreen> {
  late final DoctorAvailability _availability;
  late final DateTime _today;
  late final DateTime _lastDate;

  @override
  void initState() {
    super.initState();
    _today = DateUtils.dateOnly(widget.now());
    _lastDate = DateTime(_today.year + 1, _today.month, _today.day);
    _availability = DoctorAvailability(
      daysAvailable: widget.draft.doctor.daysAvailable,
      timeAvailable: widget.draft.doctor.timeAvailable,
    );
    _ensureSelection(widget.now());
  }

  bool _canSelectDate(DateTime date, DateTime now) =>
      !date.isBefore(_today) &&
      !date.isAfter(_lastDate) &&
      _availability.slotsForDate(date, now: now).isNotEmpty;

  void _ensureSelection(DateTime now) {
    final draft = widget.draft;
    var date = draft.date == null ? null : DateUtils.dateOnly(draft.date!);
    if (date == null || !_canSelectDate(date, now)) {
      date = null;
      if (_availability.hasSchedule) {
        for (
          var candidate = _today;
          !candidate.isAfter(_lastDate);
          candidate = DateTime(
            candidate.year,
            candidate.month,
            candidate.day + 1,
          )
        ) {
          if (_canSelectDate(candidate, now)) {
            date = candidate;
            break;
          }
        }
      }
      draft.time = null;
    }
    draft.date = date;
    if (!_selectionIsValid(now)) draft.time = null;
  }

  bool _selectionIsValid(DateTime now) {
    final draft = widget.draft;
    final scheduled = draft.scheduledAt;
    return scheduled != null &&
        _canSelectDate(draft.date!, now) &&
        _availability.slotsForDate(draft.date!, now: now).contains(scheduled);
  }

  void _continue() {
    // Recheck at the moment of navigation in case a selected slot has expired.
    if (!_selectionIsValid(widget.now())) {
      setState(() => _ensureSelection(widget.now()));
      return;
    }
    context.pushNamed(
      AppRoutes.appointmentPayment,
      pathParameters: {'doctorId': widget.draft.doctor.routeId},
      extra: widget.draft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = widget.now();
    _ensureSelection(now);
    final date = widget.draft.date;
    final slots = date == null
        ? const <DateTime>[]
        : _availability.slotsForDate(date, now: now);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select date & time'),
        centerTitle: true,
      ),
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
                      if (date == null)
                        EmptyState(
                          icon: Icons.event_busy_outlined,
                          message: _availability.hasSchedule
                              ? 'No available appointments in the next year.'
                              : 'This doctor has not provided a valid appointment schedule.',
                        )
                      else ...[
                        Card(
                          child: CalendarDatePicker(
                            key: ValueKey(date),
                            initialDate: date,
                            firstDate: _today,
                            lastDate: _lastDate,
                            selectableDayPredicate: (day) =>
                                _canSelectDate(day, now),
                            onDateChanged: (day) {
                              if (!_canSelectDate(day, widget.now())) return;
                              setState(() {
                                widget.draft.date = DateUtils.dateOnly(day);
                                widget.draft.time = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Available time slots',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '30-minute consultations · Local timezone: ${now.timeZoneName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppointmentTimeSlots(
                          slots: slots.map(TimeOfDay.fromDateTime).toList(),
                          selected: widget.draft.time,
                          onSelected: (time) {
                            final current = _availability.slotsForDate(
                              date,
                              now: widget.now(),
                            );
                            setState(() {
                              widget.draft.time =
                                  current.any(
                                    (slot) =>
                                        slot.hour == time.hour &&
                                        slot.minute == time.minute,
                                  )
                                  ? time
                                  : null;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                AppointmentContinueButton(
                  label: 'Continue to payment',
                  onPressed: _selectionIsValid(now) ? _continue : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
