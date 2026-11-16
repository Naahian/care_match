import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../domain/doctor_overview.dart';
import 'practice_stat_card.dart';

class PracticeSummaryGrid extends StatelessWidget {
  const PracticeSummaryGrid({super.key, required this.overview});
  final DoctorOverview overview;
  static String money(int value) => value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final earnings = overview.profile.totalEarnings;
    final cards = [
      PracticeStatCard(
        title: 'Upcoming consultations',
        subtitle: 'Scheduled',
        value: overview.upcomingCount.toString().padLeft(2, '0'),
        icon: Icons.calendar_month_outlined,
        color: scheme.primary,
      ),
      PracticeStatCard(
        title: 'Appointments today',
        subtitle: 'Today’s schedule',
        value: overview.today.length.toString().padLeft(2, '0'),
        icon: Icons.schedule_outlined,
        color: scheme.secondary,
      ),
      PracticeStatCard(
        title: 'In-person appointments',
        subtitle: 'Clinic visits today',
        value: overview.inPersonTodayCount.toString().padLeft(2, '0'),
        icon: Icons.people_outline,
        color: scheme.primary,
      ),
      PracticeStatCard(
        title: 'Total earnings',
        subtitle: earnings == null ? 'Not available' : 'All time · BDT',
        value: earnings == null ? '—' : '৳${money(earnings)}',
        icon: Icons.account_balance_wallet_outlined,
        color:
            Theme.of(context).extension<AppExtras>()?.warning ??
            scheme.tertiary,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 285 ||
                MediaQuery.textScalerOf(context).scale(14) > 21
            ? 1
            : 2;
        return Column(
          children: [
            for (var i = 0; i < cards.length; i += columns) ...[
              if (i > 0) const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var j = i;
                      j < i + columns && j < cards.length;
                      j++
                    ) ...[
                      if (j > i) const SizedBox(width: 12),
                      Expanded(child: cards[j]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
