import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AppointmentTimeSlots extends StatelessWidget {
  const AppointmentTimeSlots({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelected,
  });
  final List<TimeOfDay> slots;
  final TimeOfDay? selected;
  final ValueChanged<TimeOfDay> onSelected;

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
          final active = selected == slot;
          return SizedBox(
            width:
                (constraints.maxWidth - AppSpacing.sm * (columns - 1)) /
                columns,
            child: OutlinedButton(
              onPressed: () => onSelected(slot),
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
