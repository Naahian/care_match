import 'package:care_match/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/medical_report.dart';
import '../widgets/medical_report_card.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});
  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _searchController = TextEditingController();
  ReportCategory? _category;
  bool _newestFirst = true;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openReport(MedicalReport report) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: AppSpacing.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.title, style: Theme.of(context).textTheme.titleLarge),
            Text(report.doctor),
            Text(
              MaterialLocalizations.of(context).formatMediumDate(report.date),
            ),
            Text('${report.category.description} · PDF · ${report.size}'),
            const SizedBox(height: AppSpacing.md),
            // TODO: open the actual report file using its stored URL.
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final reports =
        sampleReports
            .where(
              (report) =>
                  (_category == null || report.category == _category) &&
                  '${report.title} ${report.doctor} ${report.category.description}'
                      .toLowerCase()
                      .contains(query),
            )
            .toList()
          ..sort(
            (a, b) => _newestFirst
                ? b.date.compareTo(a.date)
                : a.date.compareTo(b.date),
          );
    final latestDate = sampleReports
        .map((report) => report.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: AppSpacing.page,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search reports, tests, or doctors…',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                    ),
                    PopupMenuButton<bool>(
                      tooltip: 'Sort reports',
                      icon: const Icon(Icons.filter_list_rounded),
                      initialValue: _newestFirst,
                      onSelected: (value) =>
                          setState(() => _newestFirst = value),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: true, child: Text('Newest first')),
                        PopupMenuItem(
                          value: false,
                          child: Text('Oldest first'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _category == null,
                      onSelected: (_) => setState(() => _category = null),
                    ),
                    for (final category in ReportCategory.values)
                      ChoiceChip(
                        label: Text(category.label),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (reports.isEmpty)
                  const Padding(
                    padding: AppSpacing.card,
                    child: Text('No reports found.'),
                  ),
                for (final report in reports) ...[
                  MedicalReportCard(
                    report: report,
                    latest: report.date == latestDate,
                    onTap: () => _openReport(report),
                    onDownload: () {
                      // TODO: download the actual report from the records repository.
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: AppSpacing.card,
                    leading: Icon(
                      Icons.cloud_upload_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Upload report'),
                    subtitle: const Text(
                      'Upload lab results, imaging reports or prescriptions (PDF, JPG, PNG)',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      // TODO: pick a PDF/JPG/PNG file and upload it to the records repository.
                    },
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
