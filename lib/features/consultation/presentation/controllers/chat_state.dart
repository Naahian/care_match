import '../../domain/entities/chat.dart';

const _keep = Object();

class ChatListState {
  const ChatListState({
    this.chats = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isCreating = false,
    this.hasLoaded = false,
    this.nextCursor,
    this.error,
    this.liveError,
  });
  final List<ConsultationChat> chats;
  final bool isLoading, isLoadingMore, isCreating, hasLoaded;
  final String? nextCursor, error, liveError;
  ChatListState copyWith({
    List<ConsultationChat>? chats,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isCreating,
    bool? hasLoaded,
    Object? nextCursor = _keep,
    Object? error = _keep,
    Object? liveError = _keep,
  }) => ChatListState(
    chats: chats == null ? this.chats : List.unmodifiable(chats),
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isCreating: isCreating ?? this.isCreating,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    nextCursor: identical(nextCursor, _keep)
        ? this.nextCursor
        : nextCursor as String?,
    error: identical(error, _keep) ? this.error : error as String?,
    liveError: identical(liveError, _keep)
        ? this.liveError
        : liveError as String?,
  );
}

class PendingChatMessage {
  const PendingChatMessage(this.id, this.text);
  final String id, text;
}

class ConversationState {
  const ConversationState({
    this.chat,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSending = false,
    this.hasLoaded = false,
    this.nextCursor,
    this.error,
    this.liveError,
    this.sendError,
    this.pending,
  });
  final ConsultationChat? chat;
  final List<ConsultationMessage> messages;
  final bool isLoading, isLoadingMore, isSending, hasLoaded;
  final String? nextCursor, error, liveError, sendError;
  final PendingChatMessage? pending;
  ConversationState copyWith({
    ConsultationChat? chat,
    List<ConsultationMessage>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSending,
    bool? hasLoaded,
    Object? nextCursor = _keep,
    Object? error = _keep,
    Object? liveError = _keep,
    Object? sendError = _keep,
    Object? pending = _keep,
  }) => ConversationState(
    chat: chat ?? this.chat,
    messages: messages == null ? this.messages : List.unmodifiable(messages),
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isSending: isSending ?? this.isSending,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    nextCursor: identical(nextCursor, _keep)
        ? this.nextCursor
        : nextCursor as String?,
    error: identical(error, _keep) ? this.error : error as String?,
    liveError: identical(liveError, _keep)
        ? this.liveError
        : liveError as String?,
    sendError: identical(sendError, _keep)
        ? this.sendError
        : sendError as String?,
    pending: identical(pending, _keep)
        ? this.pending
        : pending as PendingChatMessage?,
  );
}

String chatError(Object error) => error is Exception
    ? 'Could not connect to chat. Please try again.'
    : 'Chat is unavailable. Please try again.';
