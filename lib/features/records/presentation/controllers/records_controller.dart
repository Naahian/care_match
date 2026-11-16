import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers.dart';
import '../../domain/patient_record.dart';
import '../../providers.dart';

class RecordsState {
  const RecordsState({
    this.records = const [],
    this.loading = false,
    this.loaded = false,
    this.nextOffset,
    this.error,
  });
  final List<PatientRecord> records;
  final bool loading, loaded;
  final int? nextOffset;
  final String? error;
}

final recordsControllerProvider = NotifierProvider.autoDispose
    .family<RecordsController, RecordsState, RecordKind>(RecordsController.new);

class RecordsController extends Notifier<RecordsState> {
  RecordsController(this.kind);
  final RecordKind kind;
  int _revision = 0;

  @override
  RecordsState build() {
    ref.watch(authSessionProvider);
    final revision = ++_revision;
    Future.microtask(() {
      if (ref.mounted && revision == _revision) load();
    });
    return const RecordsState();
  }

  Future<void> load({bool more = false}) async {
    if (state.loading || (more && state.nextOffset == null)) return;
    final revision = ++_revision;
    final previous = state;
    state = RecordsState(
      records: previous.records,
      loading: true,
      loaded: previous.loaded,
      nextOffset: previous.nextOffset,
    );
    try {
      final page = await ref
          .read(recordsRepositoryProvider)
          .list(kind, offset: more ? previous.nextOffset! : 0);
      if (!ref.mounted || revision != _revision) return;
      state = RecordsState(
        records: List.unmodifiable([
          if (more) ...previous.records,
          ...page.records,
        ]),
        loaded: true,
        nextOffset: page.nextOffset,
      );
    } catch (_) {
      if (!ref.mounted || revision != _revision) return;
      state = RecordsState(
        records: previous.records,
        loaded: previous.loaded,
        nextOffset: previous.nextOffset,
        error: 'Could not load records. Please try again.',
      );
    }
  }
}
