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
        content: const Text(
          'This will cancel your appointment with the doctor.',
        ),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentsControllerProvider);
    final controller = ref.read(appointmentsControllerProvider.notifier);
    final appointments = state.visibleAppointments;
    final busy = state.isLoading || state.updatingIds.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
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
            child: RefreshIndicator(
              onRefresh: () => controller.load(refresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: AppSpacing.page,
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final filter in AppointmentsFilter.values)
                                ChoiceChip(
                                  label: Text(switch (filter) {
                                    AppointmentsFilter.upcoming => 'Upcoming',
                                    AppointmentsFilter.completed => 'Completed',
                                    AppointmentsFilter.cancelled => 'Cancelled',
                                  }),
                                  selected: state.filter == filter,
                                  onSelected: (_) =>
                                      controller.selectFilter(filter),
                                ),
                            ],
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
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
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
                            isUpdating: state.updatingIds.contains(
                              entry.appointment.id,
                            ),
                            errorMessage:
                                state.updateErrors[entry.appointment.id],
                            onCancel:
                                state.uncertainIds.contains(
                                  entry.appointment.id,
                                )
                                ? null
                                : () => _cancel(entry.appointment.id),
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
