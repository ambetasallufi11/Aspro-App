import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../models/laundry.dart';
import 'api_providers.dart';

class ChatState {
  final List<ChatConversation> conversations;
  final ChatConversation? activeConversation;
  final bool isLoading;
  final String? error;

  const ChatState({
    required this.conversations,
    this.activeConversation,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatConversation>? conversations,
    ChatConversation? activeConversation,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      activeConversation: activeConversation ?? this.activeConversation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    Future.microtask(loadConversations);
    return const ChatState(conversations: []);
  }

  Future<void> loadConversations() async {
    final auth = ref.read(authProvider);
    if (auth.currentUser == null) return;
    final api = ref.read(apiClientProvider);
    final rooms = await api.chatRooms();
    final conversations = rooms.map((room) {
      final isSupport = room['is_support'] as bool? ?? false;
      final merchantId = room['merchant_id'] != null
          ? (room['merchant_id'] as int).toString()
          : 'support';
      return ChatConversation(
        id: (room['id'] as int).toString(),
        userId: (room['user_id'] as int).toString(),
        merchantId: merchantId,
        merchantName: isSupport
            ? 'Aspro Support'
            : room['merchant_name'] as String? ?? 'Merchant',
        merchantImageUrl: room['merchant_image_url'] as String?,
        messages: const [],
        lastUpdated: DateTime.now(),
        isSupport: isSupport,
      );
    }).toList();

    final filtered = auth.currentUser?.role == 'admin'
        ? conversations.where((c) => c.isSupport).toList()
        : conversations;
    state = state.copyWith(conversations: filtered);
  }

  Future<void> setActiveConversation(String conversationId) async {
    final conversation = state.conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found'),
    );
    final auth = ref.read(authProvider);
    final api = ref.read(apiClientProvider);
    final msgs = await api.chatMessages(int.parse(conversationId));
    final userId = auth.currentUser?.id ?? 0;

    final messages = msgs.map((m) {
      final senderId = m['sender_user_id'] as int;
      return ChatMessage(
        id: (m['id'] as int).toString(),
        senderId: senderId.toString(),
        receiverId: conversation.merchantId,
        content: m['text'] as String,
        timestamp: DateTime.parse(m['created_at'] as String),
        isFromUser: senderId == userId,
        type: MessageType.text,
      );
    }).toList();

    state = state.copyWith(
      activeConversation: conversation.copyWith(messages: messages),
    );
  }

  Future<void> createConversation(Laundry merchant) async {
    final api = ref.read(apiClientProvider);
    final room = await api.createRoom(merchantId: int.parse(merchant.id));
    final conversation = ChatConversation(
      id: (room['id'] as int).toString(),
      userId: (room['user_id'] as int).toString(),
      merchantId: (room['merchant_id'] as int).toString(),
      merchantName: merchant.name,
      merchantImageUrl: merchant.imageUrl,
        messages: const [],
        lastUpdated: DateTime.now(),
        isSupport: false,
    );

    state = state.copyWith(
      conversations: [...state.conversations, conversation],
      activeConversation: conversation,
    );
  }

  Future<void> createSupportConversation() async {
    final api = ref.read(apiClientProvider);
    final room = await api.createSupportRoom();
    final conversation = ChatConversation(
      id: (room['id'] as int).toString(),
      userId: (room['user_id'] as int).toString(),
      merchantId: 'support',
      merchantName: 'Aspro Support',
      merchantImageUrl: null,
      messages: const [],
      lastUpdated: DateTime.now(),
      isSupport: true,
    );

    state = state.copyWith(
      conversations: [...state.conversations, conversation],
      activeConversation: conversation,
    );
  }

  Future<void> sendTextMessage(String content) async {
    if (state.activeConversation == null) {
      state = state.copyWith(error: 'No active conversation');
      return;
    }

    final api = ref.read(apiClientProvider);
    final msg = await api.sendMessage(
      roomId: int.parse(state.activeConversation!.id),
      text: content,
    );

    final newMessage = ChatMessage(
      id: (msg['id'] as int).toString(),
      senderId: (msg['sender_user_id'] as int).toString(),
      receiverId: state.activeConversation!.merchantId,
      content: msg['text'] as String,
      timestamp: DateTime.parse(msg['created_at'] as String),
      isFromUser: true,
      type: MessageType.text,
    );

    _addMessageToConversation(newMessage);
  }

  void sendImageMessage(String imageUrl) {
    // not implemented for API MVP
  }

  void sendSpecialRequest(String request) {
    sendTextMessage(request);
  }

  void _addMessageToConversation(ChatMessage message) {
    if (state.activeConversation == null) return;

    final updatedMessages = [
      ...state.activeConversation!.messages,
      message,
    ];

    final updatedConversation = state.activeConversation!.copyWith(
      messages: updatedMessages,
      lastUpdated: DateTime.now(),
    );

    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == updatedConversation.id) {
        return updatedConversation;
      }
      return conv;
    }).toList();

    state = state.copyWith(
      conversations: updatedConversations,
      activeConversation: updatedConversation,
    );
  }

  void markConversationAsRead(String conversationId) {
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == conversationId && conv.hasUnreadMessages) {
        return conv.copyWith(hasUnreadMessages: false);
      }
      return conv;
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  List<String> getSpecialRequestTemplates({required bool isSupport}) {
    if (isSupport) {
      return [
        'Where is my order?',
        'I want to change pickup time',
        'I want to change delivery address',
        'Payment issue / refund request',
        'I need to cancel my order',
      ];
    }
    return [
      'Wash on cold and low spin',
      'Use hypoallergenic detergent',
      'Hang dry delicate items',
    ];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

final activeConversationMessagesProvider = Provider<List<ChatMessage>>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.activeConversation?.messages ?? [];
});

final conversationListProvider = Provider<List<ChatConversation>>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.conversations;
});

final specialRequestTemplatesProvider =
    Provider.family<List<String>, bool>((ref, isSupport) {
  return ref
      .watch(chatProvider.notifier)
      .getSpecialRequestTemplates(isSupport: isSupport);
});
