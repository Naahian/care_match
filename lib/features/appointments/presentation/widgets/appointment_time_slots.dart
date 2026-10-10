import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AppointmentTimeSlots extends StatelessWidget {
  const AppointmentTimeSlots({
    super.key,
    required this.date,
    required this.selected,
    required this.onSelected,
  });
  final DateTime date;
  final TimeOfDay? selected;
  final ValueChanged<TimeOfDay> onSelected;
  static const slots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 30),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 30),
    TimeOfDay(hour: 16, minute: 0),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns =
          constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(14) > 20
          ? 2
          : 3;
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: slots.map((slot) {
          final future = DateTime(
            date.year,
            date.month,
            date.day,
            slot.hour,
            slot.minute,
          ).isAfter(DateTime.now());
          final active = selected == slot;
          return SizedBox(
            width:
                (constraints.maxWidth - AppSpacing.sm * (columns - 1)) /
                columns,
            child: OutlinedButton(
              onPressed: future ? () => onSelected(slot) : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.xs,
                ),
                backgroundColor: active
                    ? Theme.of(context).colorScheme.primary
                    : null,
                foregroundColor: active
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
                side: BorderSide(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(slot),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}
