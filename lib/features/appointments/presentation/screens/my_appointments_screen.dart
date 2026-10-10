import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/appointment_entry.dart';
import '../models/appointment_draft.dart';
import '../widgets/patient_appointment_card.dart';
import '../widgets/appointment_details_sheet.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key, this.initialBooking});
  final AppointmentDraft? initialBooking;
  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late final _appointments = sampleAppointmentEntries();
  @override
  void initState() {
    super.initState();
    final booking = widget.initialBooking;
    if (booking != null && booking.scheduledAt != null) {
      _appointments.insert(
        0,
        AppointmentEntry(
          id: 'new-booking',
          doctor: booking.doctor.summary,
          dateTime: booking.scheduledAt!,
          type: booking.type,
          status: AppointmentStatus.upcoming,
          location: booking.doctor.hospital,
        ),
      );
    }
  }

  AppointmentStatus _status = AppointmentStatus.upcoming;
  void _view(AppointmentEntry appointment) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => AppointmentDetailsSheet(appointment: appointment),
    );
  }

  void _primary(AppointmentEntry appointment) {
    if (appointment.status != AppointmentStatus.upcoming) return;
    switch (appointment.type) {
      case ConsultationType.video:
        context.pushNamed(AppRoutes.video);
      case ConsultationType.chat:
        context.pushNamed(AppRoutes.chat);
      case ConsultationType.inPerson:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _appointments
        .where((appointment) => appointment.status == _status)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.page,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.goNamed(AppRoutes.home),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Home'),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: AppSpacing.page,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final status in AppointmentStatus.values)
                      ChoiceChip(
                        label: Text(switch (status) {
                          AppointmentStatus.upcoming => 'Upcoming',
                          AppointmentStatus.completed => 'Completed',
                          AppointmentStatus.cancelled => 'Cancelled',
                        }),
                        selected: _status == status,
                        onSelected: (_) => setState(() => _status = status),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (appointments.isEmpty) const Text('No appointments yet.'),
                for (final appointment in appointments) ...[
                  PatientAppointmentCard(
                    appointment: appointment,
                    onView: () => _view(appointment),
                    onPrimary: () => _primary(appointment),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
