import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../portal_controller.dart';
import '../widgets/portal_scaffold.dart';
import '../widgets/portal_schedule_tile.dart';

class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({super.key});
  static const _slots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 10, minute: 30),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 11, minute: 15),
    TimeOfDay(hour: 11, minute: 45),
    TimeOfDay(hour: 12, minute: 30),
    TimeOfDay(hour: 14, minute: 0),
  ];

  Future<void> _chooseDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: doctorPortal.selectedDate,
      firstDate: doctorPortal.today.subtract(const Duration(days: 365)),
      lastDate: doctorPortal.today.add(const Duration(days: 365)),
    );
    if (date != null) doctorPortal.selectDate(date);
  }

  void _editAvailability(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit availability'),
        content: Text(
          'Choose your availability for ${MaterialLocalizations.of(context).formatFullDate(doctorPortal.selectedDate)}. Existing appointments stay on your schedule.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              doctorPortal.setAvailable(false);
              Navigator.pop(context);
            },
            child: const Text('Unavailable'),
          ),
          FilledButton(
            onPressed: () {
              doctorPortal.setAvailable(true);
              Navigator.pop(context);
            },
            child: const Text('Available'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PortalScaffold(
    current: 2,
    title: 'Schedule',
    child: ListenableBuilder(
      listenable: doctorPortal,
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final selected = doctorPortal.selectedDate;
        final monday = selected.subtract(Duration(days: selected.weekday - 1));
        return ListView(
          padding: AppSpacing.page,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _chooseDate(context),
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  MaterialLocalizations.of(context).formatMediumDate(selected),
                ),
              ),
            ),
            SizedBox(
              height:
                  MediaQuery.textScalerOf(context).scale(64) + AppSpacing.lg,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final day = monday.add(Duration(days: index));
                  final active = day == selected;
                  return Semantics(
                    selected: active,
                    button: true,
                    label: MaterialLocalizations.of(
                      context,
                    ).formatFullDate(day),
                    child: InkWell(
                      onTap: () => doctorPortal.selectDate(day),
                      borderRadius: AppRadius.card,
                      child: Container(
                        width: MediaQuery.textScalerOf(context).scale(52),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: active ? scheme.primary : Colors.transparent,
                          borderRadius: AppRadius.card,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              const [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ][index],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: active
                                    ? scheme.onPrimary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${day.day}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: active
                                    ? scheme.onPrimary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              color: scheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      doctorPortal.available
                          ? '●  Available for appointments'
                          : '●  Unavailable for appointments',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _editAvailability(context),
                      child: const Text('Edit availability'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final time in _slots)
              PortalScheduleTile(
                time: time,
                patient: doctorPortal.bookingAt(time),
                isBreak: time.hour == 12,
              ),
          ],
        );
      },
    ),
  );
}
