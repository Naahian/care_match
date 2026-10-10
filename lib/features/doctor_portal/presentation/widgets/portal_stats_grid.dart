import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import 'portal_stat_card.dart';

class PortalStatsGrid extends StatelessWidget {
  const PortalStatsGrid({super.key, required this.cards});
  final List<PortalStatCard> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scaler = MediaQuery.textScalerOf(context);
      final columns = constraints.maxWidth >= 640
          ? 4
          : constraints.maxWidth < 350 && scaler.scale(14) > 18
          ? 1
          : 2;
      final width =
          (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
      // Match the card's padding, 40px icon, and gap. Measure the tallest
      // label so the entire grid grows together with accessible text sizes.
      final textWidth = width - AppSpacing.md * 2 - 40 - AppSpacing.sm;
      final textTheme = Theme.of(context).textTheme;
      double textHeight(String text, TextStyle? style) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: scaler,
          locale: Localizations.localeOf(context),
        )..layout(maxWidth: textWidth);
        final height = painter.height;
        painter.dispose();
        return height;
      }

      var contentHeight = 40.0;
      for (final card in cards) {
        contentHeight = math.max(
          contentHeight,
          textHeight(
                card.value,
                textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ) +
              textHeight(card.label, textTheme.bodySmall),
        );
      }
      return GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        mainAxisExtent: (contentHeight + AppSpacing.md * 2).ceilToDouble(),
        children: cards,
      );
    },
  );
}
