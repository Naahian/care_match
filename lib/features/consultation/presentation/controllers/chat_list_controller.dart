import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../providers.dart';
import 'chat_state.dart';

final chatListControllerProvider =
    NotifierProvider.autoDispose<ChatListController, ChatListState>(
      ChatListController.new,
    );

class ChatListController extends Notifier<ChatListState> {
  StreamSubscription<List<ConsultationChat>>? _subscription;
  int _revision = 0;
  String? _uid;

  @override
  ChatListState build() {
    _uid = ref.watch(consultationUserProvider);
    _revision++;
    ref.onDispose(() {
      _revision++;
      unawaited(_subscription?.cancel());
      _subscription = null;
    });
    return ChatListState(
      error: _uid == null ? 'Sign in to view your conversations.' : null,
    );
  }

  bool _active(int revision) => ref.mounted && _revision == revision;
  List<ConsultationChat> _merge(List<ConsultationChat> incoming) {
    final byId = {for (final chat in state.chats) chat.id: chat};
    for (final chat in incoming) {
      final old = byId[chat.id];
      if (old == null || !old.updatedAt.isAfter(chat.updatedAt)) {
        byId[chat.id] = chat;
      }
    }
    return byId.values.toList()..sort((a, b) {
      final time = b.updatedAt.compareTo(a.updatedAt);
      return time == 0 ? b.id.compareTo(a.id) : time;
    });
  }

  void _checkMember(ConsultationChat chat) {
    if (!chat.participantUids.contains(_uid)) {
      throw const ChatException(
        'This conversation is unavailable.',
        accessDenied: true,
      );
    }
  }

  void _failure(Object error, {bool live = false, bool creating = false}) {
    final message = error is ChatException ? error.message : chatError(error);
    if (error is ChatException && error.accessDenied) {
      _revision++;
      unawaited(_subscription?.cancel());
      state = ChatListState(error: message);
    } else {
      state = state.copyWith(
        isLoading: live || creating ? state.isLoading : false,
        isLoadingMore: live || creating ? state.isLoadingMore : false,
        isCreating: creating ? false : state.isCreating,
        error: live ? state.error : message,
        liveError: live ? message : state.liveError,
      );
    }
  }

  Future<void> load({bool more = false}) async {
    if (_uid == null ||
        state.isLoading ||
        state.isLoadingMore ||
        (more && state.nextCursor == null)) {
      return;
    }
    final revision = _revision;
    state = state.copyWith(isLoading: !more, isLoadingMore: more, error: null);
    try {
      final repository = ref.read(chatRepositoryProvider);
      final page = await repository.listChats(
        cursor: more ? state.nextCursor : null,
      );
      if (!_active(revision)) return;
      for (final chat in page.items) {
        _checkMember(chat);
      }
      state = state.copyWith(
        chats: _merge(page.items),
        isLoading: false,
        isLoadingMore: false,
        hasLoaded: true,
        nextCursor: page.nextCursor,
      );
      if (!more) {
        await _subscription?.cancel();
        if (!_active(revision)) return;
        _subscription = repository
            .watchChats(_uid!)
            .listen(
              (chats) {
                if (!_active(revision)) return;
                try {
                  for (final chat in chats) {
                    _checkMember(chat);
                  }
                  state = state.copyWith(
                    chats: _merge(chats),
                    nextCursor:
                        state.nextCursor ??
                        (chats.length == 20 ? chats.last.id : null),
                    liveError: null,
                  );
                } catch (error) {
                  _failure(error, live: true);
                }
              },
              onError: (Object error) {
                if (_active(revision)) _failure(error, live: true);
              },
            );
      }
    } catch (error) {
      if (_active(revision)) _failure(error);
    }
  }

  Future<ConsultationChat?> startChat(String recipientUid) async {
    if (_uid == null || state.isCreating) return null;
    final revision = _revision;
    state = state.copyWith(isCreating: true, error: null);
    try {
      final chat = await ref
          .read(chatRepositoryProvider)
          .createChat(recipientUid);
      if (!_active(revision)) return null;
      _checkMember(chat);
      state = state.copyWith(chats: _merge([chat]), isCreating: false);
      return chat;
    } catch (error) {
      if (_active(revision)) _failure(error, creating: true);
      return null;
    }
  }
}
