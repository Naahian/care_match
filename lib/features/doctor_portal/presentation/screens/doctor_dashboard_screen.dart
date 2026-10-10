import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../portal_controller.dart';
import '../models/portal_patient.dart';
import '../widgets/portal_scaffold.dart';
import '../widgets/portal_stat_card.dart';
import '../widgets/portal_stats_grid.dart';
import '../widgets/portal_patient_summary.dart';
import '../widgets/portal_patient_sheet.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => PortalScaffold(
    current: 0,
    child: ListenableBuilder(
      listenable: doctorPortal,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final next = doctorPortal.nextPatient;
        final hour = TimeOfDay.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
        return ListView(
          padding: AppSpacing.page,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: BrandHeader(),
                        ),
                      ),
                      Text(
                        'Doctor Portal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => context.pushNamed(AppRoutes.preferences),
                  color: scheme.primary,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$greeting,\n${doctorPortal.name}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Here’s your overview for today.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            PortalStatsGrid(
              cards: [
                PortalStatCard(
                  icon: Icons.calendar_month_outlined,
                  value: '${doctorPortal.patients.length}',
                  label: 'Today’s appointments',
                  onTap: () {
                    doctorPortal.selectDate(doctorPortal.today);
                    context.goNamed(AppRoutes.doctorSchedule);
                  },
                ),
                PortalStatCard(
                  icon: Icons.people_outline_rounded,
                  value: '${doctorPortal.count(QueueStatus.waiting)}',
                  label: 'Pending patients',
                  onTap: () => context.goNamed(AppRoutes.doctorQueue),
                ),
                const PortalStatCard(
                  icon: Icons.paid_outlined,
                  value: r'$480',
                  label: 'Earnings this week',
                  green: true,
                ),
                PortalStatCard(
                  icon: Icons.circle,
                  value: doctorPortal.availableOn(doctorPortal.today)
                      ? 'Available'
                      : 'Away',
                  label: 'Status today',
                  green: true,
                  onTap: () => context.goNamed(AppRoutes.doctorSchedule),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (next != null)
              Card(
                color: scheme.primaryContainer,
                child: Padding(
                  padding: AppSpacing.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Next consultation',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Card(
                        child: Padding(
                          padding: AppSpacing.card,
                          child: PortalPatientSummary(patient: next),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton.icon(
                        onPressed: () => showPortalPatient(
                          context,
                          next,
                          startConsult: true,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Join consult'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: AppSpacing.card,
                  child: Text(
                    'No patients waiting. You’re all caught up.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
