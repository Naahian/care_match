import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../../shared/widgets/bottom_navbar.dart';
import '../../../appointments/domain/entities/appointment.dart';
import '../controllers/doctor_home_controller.dart';
import '../widgets/doctor_today_appointment.dart';
import '../widgets/practice_action_card.dart';
import '../widgets/practice_summary_grid.dart';
import '../widgets/doctor_appointment_sheet.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});
  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (mounted) unawaited(_load());
    });
  }

  Future<void> _load() =>
      ref.read(doctorHomeControllerProvider.notifier).load();

  void _appointments() => context.pushNamed(AppRoutes.appointments);
  void _view(Appointment appointment) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DoctorAppointmentSheet(appointment: appointment),
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorHomeControllerProvider);
    final overview = state.overview;
    final theme = Theme.of(context);
    final now = overview?.now.toLocal() ?? DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(current: 0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: BrandHeader(compact: true),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () =>
                            context.pushNamed(AppRoutes.preferences),
                        icon: const Icon(Icons.tune_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.card,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    MaterialLocalizations.of(context).formatMediumDate(now),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$greeting,\nDoctor',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Here’s your practice at a glance.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.loading) const LinearProgressIndicator(),
                  if (state.error != null) ...[
                    Text(
                      state.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    TextButton(
                      onPressed: state.loading ? null : _load,
                      child: const Text('Retry'),
                    ),
                  ],
                  if (overview != null) ...[
                    PracticeSummaryGrid(overview: overview),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Practice tools', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final actions = [
                          PracticeActionCard(
                            title: 'Prescription',
                            subtitle: 'View patient appointments',
                            icon: Icons.description_outlined,
                            onTap: _appointments,
                          ),
                          PracticeActionCard(
                            title: 'All appointments',
                            subtitle: 'View your schedule',
                            icon: Icons.calendar_month_outlined,
                            secondary: true,
                            onTap: _appointments,
                          ),
                        ];
                        if (constraints.maxWidth < 285 ||
                            MediaQuery.textScalerOf(context).scale(14) > 21) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              actions[0],
                              const SizedBox(height: AppSpacing.sm),
                              actions[1],
                            ],
                          );
                        }
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: actions[0]),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: actions[1]),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Today’s appointments',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _appointments,
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (overview.today.isEmpty)
                      Card(
                        child: Padding(
                          padding: AppSpacing.card,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No appointments scheduled for today.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (final appointment in overview.today) ...[
                      DoctorTodayAppointment(
                        appointment: appointment,
                        onView: () => _view(appointment),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
