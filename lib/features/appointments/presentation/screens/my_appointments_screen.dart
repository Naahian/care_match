import 'package:care_match/shared/widgets/care_app_bar.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../controllers/appointments_controller.dart';
import '../controllers/appointments_state.dart';
import '../widgets/appointment_card_shimmer.dart';
import '../widgets/patient_appointment_card.dart';
import '../../domain/entities/appointment.dart';
import '../../../consultation/presentation/widgets/upcoming_consultation.dart';

class MyAppointmentsScreen extends ConsumerStatefulWidget {
  const MyAppointmentsScreen({super.key, this.refreshOnOpen = false});

  final bool refreshOnOpen;

  @override
  ConsumerState<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends ConsumerState<MyAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (mounted) {
        unawaited(
          ref
              .read(appointmentsControllerProvider.notifier)
              .load(refresh: widget.refreshOnOpen),
        );
      }
    });
  }

  Future<void> _cancel(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: const Text('This will cancel the appointment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep appointment'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(appointmentsControllerProvider.notifier)
          .cancelAppointment(id);
    }
  }

  Future<void> _complete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete appointment?'),
        content: const Text('This will mark the appointment as completed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep appointment'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as completed'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(appointmentsControllerProvider.notifier)
          .completeAppointment(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentsControllerProvider);
    final controller = ref.read(appointmentsControllerProvider.notifier);
    final appointments = state.visibleAppointments;
    final busy = state.isLoading || state.updatingIds.isNotEmpty;
    return Scaffold(
      appBar: careAppBar(
        context,
        title: const Text('My care'),
        actions: [
          IconButton(
            tooltip: 'Refresh appointments',
            onPressed: busy ? null : () => controller.load(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    minimumSize: const Size(0, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.card,
                    ),
                  ),
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
            child: RefreshIndicator(
              onRefresh: () => controller.load(refresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'My appointments',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your upcoming care.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 24),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: AppRadius.card,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  for (final filter
                                      in AppointmentsFilter.values)
                                    Expanded(
                                      child: ChoiceChip(
                                        showCheckmark: false,
                                        side: BorderSide.none,
                                        labelPadding: EdgeInsets.zero,
                                        padding: EdgeInsets.zero,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: AppRadius.button,
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        selectedColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: state.filter == filter
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                        label: Center(
                                          child: Text(switch (filter) {
                                            AppointmentsFilter.upcoming =>
                                              'Upcoming',
                                            AppointmentsFilter.completed =>
                                              'Completed',
                                            AppointmentsFilter.cancelled =>
                                              'Cancelled',
                                          }, textAlign: TextAlign.center),
                                        ),
                                        selected: state.filter == filter,
                                        onSelected: (_) =>
                                            controller.selectFilter(filter),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (state.isLoading)
                            for (var i = 0; i < 3; i++) ...[
                              const AppointmentCardShimmer(),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          if (state.errorMessage != null) ...[
                            Text(state.errorMessage!),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () => controller.load(refresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                          if (!state.isLoading &&
                              state.doctorDetailsUnavailable) ...[
                            const Text(
                              'Some doctor details are unavailable. You can still manage your appointments.',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.hasLoaded &&
                      !state.isLoading &&
                      state.errorMessage == null &&
                      appointments.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.event_note_outlined,
                        message: switch (state.filter) {
                          AppointmentsFilter.upcoming =>
                            'No upcoming appointments.',
                          AppointmentsFilter.completed =>
                            'No completed appointments.',
                          AppointmentsFilter.cancelled =>
                            'No cancelled appointments.',
                        },
                      ),
                    ),
                  if (!state.isLoading && appointments.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      sliver: SliverList.separated(
                        itemCount: appointments.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final entry = appointments[index];
                          return PatientAppointmentCard(
                            key: ValueKey(entry.appointment.id),
                            appointment: entry,
                            role: state.role,
                            isUpdating: state.updatingIds.contains(
                              entry.appointment.id,
                            ),
                            errorMessage:
                                state.updateErrors[entry.appointment.id],
                            onComplete:
                                state.uncertainIds.contains(
                                  entry.appointment.id,
                                )
                                ? null
                                : () => _complete(entry.appointment.id),
                            onOpenChat: () => context.pushNamed(
                              AppRoutes.chat,
                              queryParameters: {
                                'recipient':
                                    state.role == AppointmentRole.doctor
                                    ? entry.appointment.patientId
                                    : entry.appointment.doctorId,
                              },
                            ),
                            onCancel:
                                state.uncertainIds.contains(
                                  entry.appointment.id,
                                )
                                ? null
                                : () => _cancel(entry.appointment.id),
                            onJoinVideo: () {
                              final date = entry.appointment.scheduledFor
                                  .toLocal();
                              final localizations = MaterialLocalizations.of(
                                context,
                              );
                              context.pushNamed(
                                AppRoutes.video,
                                queryParameters: {
                                  'appointmentId': entry.appointment.id,
                                },
                                extra: UpcomingConsultation(
                                  doctorName:
                                      (state.role == AppointmentRole.doctor
                                          ? entry.appointment.patientName ??
                                                entry
                                                    .appointment
                                                    .patient
                                                    ?.name ??
                                                'Patient'
                                          : entry.doctor?.name) ??
                                      'Doctor details unavailable',
                                  specialty:
                                      (state.role == AppointmentRole.doctor
                                          ? 'Patient consultation'
                                          : entry.doctor?.specialties.join(
                                              ', ',
                                            )) ??
                                      'Specialty not provided',
                                  schedule:
                                      '${localizations.formatMediumDate(date)} · '
                                      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}',
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
