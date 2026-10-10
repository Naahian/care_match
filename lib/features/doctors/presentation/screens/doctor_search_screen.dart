import 'package:care_match/features/doctors/presentation/widgets/doctor_profile.dart';
import 'package:care_match/core/constants/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:care_match/core/constants/constants.dart';
import 'package:care_match/shared/widgets/brand_header.dart';
import 'package:care_match/shared/widgets/bottom_navbar.dart';
import 'package:flutter/material.dart';

import 'package:care_match/shared/widgets/doctor_card.dart';
import '../widgets/doctor_search_field.dart';
import '../widgets/doctor_summary.dart';
import '../widgets/find_doctor_title_block.dart';
import '../widgets/nearby_doctors_header.dart';
import '../widgets/specialty_strip.dart';

/// "Find a Doctor" search screen: symptom/specialty search, specialty
/// shortcuts and a list of nearby doctors.
class FindDoctorScreen extends StatefulWidget {
  const FindDoctorScreen({super.key, this.initialQuery = ''});
  final String initialQuery;

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void didUpdateWidget(covariant FindDoctorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _searchController.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    // TODO: fetch doctor results for this query.
    context.goNamed(AppRoutes.doctors, queryParameters: {'query': query});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(current: 1),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
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
                const SliverToBoxAdapter(child: SpecialtyStrip()),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(child: NearbyDoctorsHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.lg,
                  ),
                  sliver: SliverList.separated(
                    itemCount: sampleDoctors.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) => DoctorCard(
                      doctor: sampleDoctors[index],
                      highlightAlt: !sampleDoctors[index].availableToday,
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.doctorDetail,
                          pathParameters: {
                            'doctorId': doctorProfileId(
                              sampleDoctors[index].name,
                            ),
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
