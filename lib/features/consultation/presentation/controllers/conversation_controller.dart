import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../providers.dart';
import 'chat_state.dart';

final conversationControllerProvider = NotifierProvider.autoDispose
    .family<ConversationController, ConversationState, String>(
      ConversationController.new,
    );

class ConversationController extends Notifier<ConversationState> {
  ConversationController(this.chatId);
  final String chatId;
  StreamSubscription<List<ConsultationMessage>>? _subscription;
  String? _uid;
  int _revision = 0;
  bool _refreshing = false;
  bool _refreshRequested = false;

  @override
  ConversationState build() {
    _uid = ref.watch(consultationUserProvider);
    _revision++;
    _refreshing = false;
    _refreshRequested = false;
    ref.onDispose(() {
      _revision++;
      unawaited(_subscription?.cancel());
      _subscription = null;
    });
    return ConversationState(
      error: _uid == null ? 'Sign in to view this conversation.' : null,
    );
  }

  bool _active(int revision) => ref.mounted && revision == _revision;
  List<ConsultationMessage> _merge(List<ConsultationMessage> incoming) {
    final members = state.chat?.participantUids ?? const <String>[];
    if (incoming.any(
      (m) => m.chatId != chatId || !members.contains(m.senderUid),
    )) {
      throw const ChatException(
        'This conversation is unavailable.',
        accessDenied: true,
      );
    }
    final byId = {for (final m in state.messages) m.id: m};
    for (final message in incoming) {
      byId[message.id] = message;
    }
    return byId.values.toList()..sort((a, b) {
      final time = b.createdAt.compareTo(a.createdAt);
      return time == 0 ? b.id.compareTo(a.id) : time;
    });
  }

  void _failure(Object error, {bool live = false, bool sending = false}) {
    final message = error is ChatException ? error.message : chatError(error);
    if (error is ChatException && error.accessDenied) {
      _revision++;
      _refreshing = false;
      unawaited(_subscription?.cancel());
      state = ConversationState(error: message);
    } else {
      state = state.copyWith(
        isLoading: live || sending ? state.isLoading : false,
        isLoadingMore: live || sending ? state.isLoadingMore : false,
        isSending: sending ? false : state.isSending,
        error: live || sending ? state.error : message,
        liveError: live ? message : state.liveError,
        sendError: sending ? message : state.sendError,
        pending: sending && error is ChatException && !error.mayHaveSucceeded
            ? null
            : state.pending,
      );
    }
  }

  Future<void> open() async {
    if (_uid == null || state.isLoading) return;
    final revision = ++_revision;
    // A reconnect owns a new catch-up operation. An older request must not
    // block it or reset its progress when that request eventually completes.
    _refreshing = false;
    _refreshRequested = false;
    final knownBefore = state.messages.map((message) => message.id).toSet();
    state = state.copyWith(isLoading: true, isSending: false, error: null);
    await _subscription?.cancel();
    if (!_active(revision)) return;
    try {
      final repository = ref.read(chatRepositoryProvider);
      final chat = await repository.getChat(chatId);
      if (!_active(revision)) return;
      if (!chat.participantUids.contains(_uid)) {
        throw const ChatException(
          'This conversation is unavailable.',
          accessDenied: true,
        );
      }
      state = state.copyWith(chat: chat);
      final page = await repository.listMessages(chatId);
      if (!_active(revision)) return;
      state = state.copyWith(
        messages: _merge(page.items),
        isLoading: false,
        hasLoaded: true,
        nextCursor: state.hasLoaded ? state.nextCursor : page.nextCursor,
      );
      if (knownBefore.isNotEmpty) {
        await refresh(knownIds: knownBefore);
        if (!_active(revision)) return;
      }
      _subscription = repository
          .watchMessages(chatId)
          .listen(
            (messages) {
              if (!_active(revision)) return;
              try {
                final previousIds = state.messages.map((m) => m.id).toSet();
                final gap =
                    messages.isNotEmpty &&
                    !messages.any((m) => previousIds.contains(m.id));
                state = state.copyWith(
                  messages: _merge(messages),
                  liveError: null,
                );
                if (gap) unawaited(refresh(knownIds: previousIds));
              } catch (error) {
                _failure(error, live: true);
              }
            },
            onError: (Object error) {
              if (_active(revision)) _failure(error, live: true);
            },
          );
    } catch (error) {
      if (_active(revision)) _failure(error);
    }
  }

  Future<void> loadOlder() async {
    if (_uid == null ||
        state.chat == null ||
        state.isLoading ||
        state.isLoadingMore ||
        state.nextCursor == null) {
      return;
    }
    final revision = _revision;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final page = await ref
          .read(chatRepositoryProvider)
          .listMessages(chatId, cursor: state.nextCursor);
      if (!_active(revision)) return;
      state = state.copyWith(
        messages: _merge(page.items),
        nextCursor: page.nextCursor,
        isLoadingMore: false,
      );
    } catch (error) {
      if (_active(revision)) _failure(error);
    }
  }

  // Catch up after resuming or a live window jumping past the loaded history.
  Future<void> refresh({Set<String>? knownIds}) async {
    if (_uid == null || state.chat == null) return;
    if (_refreshing) {
      _refreshRequested = true;
      return;
    }
    _refreshing = true;
    final revision = _revision;
    final known = knownIds ?? state.messages.map((m) => m.id).toSet();
    try {
      do {
        _refreshRequested = false;
        String? cursor;
        final seen = <String>{};
        do {
          final page = await ref
              .read(chatRepositoryProvider)
              .listMessages(chatId, cursor: cursor);
          if (!_active(revision)) return;
          final reachedKnown = page.items.any((m) => known.contains(m.id));
          state = state.copyWith(messages: _merge(page.items));
          cursor = page.nextCursor;
          if (reachedKnown || cursor == null || !seen.add(cursor)) break;
        } while (true);
        // Keep the original anchor: newer live snapshots are already merged
        // into state and cannot prove that the intervening history was loaded.
      } while (_refreshRequested);
    } catch (error) {
      if (_active(revision)) _failure(error, live: true);
    } finally {
      if (_active(revision)) _refreshing = false;
    }
  }

  Future<bool> send(String input) async {
    final text = input.trim();
    if (_uid == null || state.chat == null || state.isSending || text.isEmpty) {
      return false;
    }
    if (text.length > 4000) {
      state = state.copyWith(
        sendError: 'Messages must be 4000 characters or fewer.',
      );
      return false;
    }
    final pending = state.pending;
    if (pending != null && pending.text != text) {
      state = state.copyWith(
        sendError: 'Retry the pending message before sending another.',
      );
      return false;
    }
    final outgoing =
        pending ?? PendingChatMessage(ref.read(chatMessageIdProvider)(), text);
    final revision = _revision;
    state = state.copyWith(isSending: true, pending: outgoing, sendError: null);
    try {
      final message = await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            chatId,
            text: outgoing.text,
            clientMessageId: outgoing.id,
          );
      if (!_active(revision)) return false;
      if (message.senderUid != _uid) {
        throw const ChatException('Could not confirm the sender.');
      }
      state = state.copyWith(
        messages: _merge([message]),
        isSending: false,
        pending: null,
        sendError: null,
      );
      return true;
    } catch (error) {
      if (_active(revision)) _failure(error, sending: true);
      return false;
    }
  }
}
