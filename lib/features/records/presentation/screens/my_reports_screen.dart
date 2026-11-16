import 'package:care_match/shared/widgets/care_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/patient_record.dart';
import '../controllers/records_controller.dart';
import '../widgets/record_viewer.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: careAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'My reports',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your medical documents, in one place.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: AppRadius.card,
                        ),
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: AppRadius.button,
                          ),
                          indicatorPadding: const EdgeInsets.all(4),
                          dividerColor: Colors.transparent,
                          labelColor: Theme.of(context).colorScheme.onPrimary,
                          unselectedLabelColor: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                          tabs: const [
                            Tab(text: 'Medical Reports'),
                            Tab(text: 'Prescriptions'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _RecordsList(kind: RecordKind.medicalReports),
                  _RecordsList(kind: RecordKind.prescriptions),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RecordsList extends ConsumerStatefulWidget {
  const _RecordsList({required this.kind});
  final RecordKind kind;
  @override
  ConsumerState<_RecordsList> createState() => _RecordsListState();
}

class _RecordsListState extends ConsumerState<_RecordsList> {
  Future<void> _load() =>
      ref.read(recordsControllerProvider(widget.kind).notifier).load();

  Future<void> _open(PatientRecord record) async {
    if (!record.expiresAt.isAfter(DateTime.now())) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Download link expired. Records refreshed; open the record again.',
          ),
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => RecordViewer(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordsControllerProvider(widget.kind));
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (state.loading) const LinearProgressIndicator(),
              if (state.error != null) ...[
                Text(state.error!),
                TextButton(
                  onPressed: state.loading ? null : _load,
                  child: const Text('Retry'),
                ),
              ],
              if (state.loaded && !state.loading && state.records.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.kind == RecordKind.prescriptions
                        ? 'No prescriptions yet.'
                        : 'No medical reports yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              if (state.records.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.kind == RecordKind.prescriptions
                            ? 'Prescriptions'
                            : 'Medical reports',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${state.records.length} ${state.records.length == 1 ? 'file' : 'files'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              for (final record in state.records) ...[
                Card(
                  child: Padding(
                    padding: AppSpacing.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            record.isImage
                                ? Icons.image_outlined
                                : Icons.description_outlined,
                          ),
                          title: Text(record.filename),
                          subtitle: Text(
                            [
                              if (record.createdAt != null)
                                MaterialLocalizations.of(
                                  context,
                                ).formatMediumDate(record.createdAt!.toLocal()),
                              record.contentType,
                              '${(record.sizeBytes / 1024).ceil()} KB',
                            ].join('\n'),
                          ),
                          onTap: () => _open(record),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _open(record),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.open_in_full),
                          label: Text(
                            widget.kind == RecordKind.prescriptions
                                ? 'View prescription'
                                : 'View report',
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.card,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (state.nextOffset != null)
                TextButton(
                  onPressed: state.loading
                      ? null
                      : () => ref
                            .read(
                              recordsControllerProvider(widget.kind).notifier,
                            )
                            .load(more: true),
                  child: const Text('Load more'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
