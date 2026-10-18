import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/doctors_controller.dart';
import '../widgets/doctors_results.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/brand_header.dart';
import 'package:care_match/shared/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

import '../widgets/doctor_search_field.dart';
import '../widgets/find_doctor_title_block.dart';
import '../widgets/specialty_strip.dart';

/// Searches and filters the API doctor directory.
class FindDoctorScreen extends ConsumerStatefulWidget {
  const FindDoctorScreen({super.key, this.initialQuery = ''});
  final String initialQuery;

  @override
  ConsumerState<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends ConsumerState<FindDoctorScreen> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      if (!mounted) return;
      final controller = ref.read(doctorsControllerProvider.notifier);
      controller.search(widget.initialQuery);
      unawaited(controller.load());
    });
  }

  @override
  void didUpdateWidget(covariant FindDoctorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _searchController.text = widget.initialQuery;
      scheduleMicrotask(() {
        if (mounted) {
          ref
              .read(doctorsControllerProvider.notifier)
              .search(widget.initialQuery);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    ref.read(doctorsControllerProvider.notifier).search(query);
    context.goNamed(AppRoutes.doctors, queryParameters: {'query': query});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorsControllerProvider);
    return Scaffold(
      bottomNavigationBar: BottomNavBar(current: 1),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(doctorsControllerProvider.notifier)
                  .load(refresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const BrandHeader(),
                        const SizedBox(height: AppSpacing.lg),
                        const FindDoctorTitleBlock(),
                        const SizedBox(height: AppSpacing.lg),
                        DoctorSearchField(
                          controller: _searchController,
                          onSubmit: _submitSearch,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SpecialtyStrip(
                      specialties:
                          (state.doctors
                              .expand((d) => d.specialties)
                              .toSet()
                              .toList()
                            ..sort()),
                      selected: state.specialty,
                      onSelected: ref
                          .read(doctorsControllerProvider.notifier)
                          .selectSpecialty,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Doctors',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh doctors',
                            onPressed: state.isLoading
                                ? null
                                : () => ref
                                      .read(doctorsControllerProvider.notifier)
                                      .load(refresh: true),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: DoctorsResults(
                        state: state,
                        onRetry: () => ref
                            .read(doctorsControllerProvider.notifier)
                            .load(refresh: true),
                      ),
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
