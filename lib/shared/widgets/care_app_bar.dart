import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';

AppBar careAppBar(
  BuildContext context, {
  Widget? title,
  List<Widget>? actions,
}) {
  final theme = Theme.of(context);
  return AppBar(
    title: title,
    titleTextStyle: theme.textTheme.titleMedium,
    centerTitle: false,
    leadingWidth: 66,
    titleSpacing: 14,
    leading: Navigator.of(context).canPop()
        ? Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: Center(
              child: BackButton(
                color: theme.colorScheme.onSurface,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                  ),
                ),
              ),
            ),
          )
        : null,
    actions: actions,
  );
}
