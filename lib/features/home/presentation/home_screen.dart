import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/bottom_navbar.dart';
import 'package:care_match/shared/widgets/brand_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/home_controller.dart';
import 'widgets/featured_doctors_section.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/symptom_card.dart';

/// Patient home screen: symptom search, quick actions and featured doctors.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(homeControllerProvider.notifier).loadDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    context.pushNamed(
      AppRoutes.symptomEntry,
      queryParameters: {'symptoms': query},
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(homeControllerProvider.notifier)
                  .loadDoctors(refresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.lg,
                ),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: BrandHeader(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        tooltip: 'Settings',
                        color: Theme.of(context).colorScheme.primary,
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () =>
                            context.pushNamed(AppRoutes.preferences),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SymptomCard(
                    controller: _searchController,
                    onSubmit: _submitSearch,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const QuickActionsRow(),
                  const SizedBox(height: AppSpacing.lg),
                  FeaturedDoctorsSection(
                    state: home,
                    onRetry: () => ref
                        .read(homeControllerProvider.notifier)
                        .loadDoctors(refresh: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(current: 0),
    );
  }
}
