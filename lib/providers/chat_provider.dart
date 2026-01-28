import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_chat_data.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../models/laundry.dart';
import 'mock_providers.dart';

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
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(
      conversations: MockChatData.conversations,
    );
  }

  // Set the active conversation
  void setActiveConversation(String conversationId) {
    final conversation = state.conversations.firstWhere(
      (conv) => conv.id == conversationId,
      orElse: () => throw Exception('Conversation not found'),
    );

    state = state.copyWith(activeConversation: conversation);
  }

  // Create a new conversation with a merchant
  void createConversation(Laundry merchant) {
    final userId = MockChatData.currentUserId;
    final existingConversation = state.conversations.firstWhere(
      (conv) => conv.merchantId == merchant.id && conv.userId == userId,
      orElse: () => ChatConversation.fromLaundry(merchant, userId),
    );

    if (!state.conversations.any((conv) => conv.id == existingConversation.id)) {
      final updatedConversations = [...state.conversations, existingConversation];
      state = state.copyWith(
        conversations: updatedConversations,
        activeConversation: existingConversation,
      );
    } else {
      state = state.copyWith(activeConversation: existingConversation);
    }
  }

  // Send a text message
  void sendTextMessage(String content) {
    if (state.activeConversation == null) {
      state = state.copyWith(error: 'No active conversation');
      return;
    }

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: MockChatData.currentUserId,
      receiverId: state.activeConversation!.merchantId,
      content: content,
      timestamp: DateTime.now(),
      isFromUser: true,
      type: MessageType.text,
    );

    _addMessageToConversation(newMessage);
  }

  // Send an image message
  void sendImageMessage(String imageUrl) {
    if (state.activeConversation == null) {
      state = state.copyWith(error: 'No active conversation');
      return;
    }

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: MockChatData.currentUserId,
      receiverId: state.activeConversation!.merchantId,
      content: imageUrl,
      timestamp: DateTime.now(),
      isFromUser: true,
      type: MessageType.image,
      imageUrl: imageUrl,
    );

    _addMessageToConversation(newMessage);
  }

  // Send a special request
  void sendSpecialRequest(String request) {
    if (state.activeConversation == null) {
      state = state.copyWith(error: 'No active conversation');
      return;
    }

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: MockChatData.currentUserId,
      receiverId: state.activeConversation!.merchantId,
      content: request,
      timestamp: DateTime.now(),
      isFromUser: true,
      type: MessageType.specialRequest,
    );

    _addMessageToConversation(newMessage);
  }

  // Helper method to add a message to the active conversation
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

    // Simulate merchant response after a delay (for demo purposes)
    if (kDebugMode) {
      Future.delayed(const Duration(seconds: 2), () {
        _simulateMerchantResponse(message);
      });
    }
  }

  // Simulate merchant response (for demo purposes)
  void _simulateMerchantResponse(ChatMessage userMessage) {
    if (state.activeConversation == null) return;

    String responseContent;
    MessageType responseType = MessageType.text;

    switch (userMessage.type) {
      case MessageType.text:
        responseContent = 'Thanks for your message! We\'ll get back to you shortly.';
        break;
      case MessageType.image:
        responseContent = 'Thanks for sharing the image. We\'ll take a look at it.';
        break;
      case MessageType.specialRequest:
        responseContent = 'We\'ve noted your special request: "${userMessage.content}". We\'ll make sure to follow these instructions.';
        break;
    }

    final responseMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: state.activeConversation!.merchantId,
      receiverId: MockChatData.currentUserId,
      content: responseContent,
      timestamp: DateTime.now(),
      isFromUser: false,
      type: responseType,
    );

    final updatedMessages = [
      ...state.activeConversation!.messages,
      responseMessage,
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

  // Mark conversation as read
  void markConversationAsRead(String conversationId) {
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == conversationId && conv.hasUnreadMessages) {
        return conv.copyWith(hasUnreadMessages: false);
      }
      return conv;
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  // Get special request templates
  List<String> getSpecialRequestTemplates() {
    return MockChatData.specialRequestTemplates;
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

// Provider for active conversation messages
final activeConversationMessagesProvider = Provider<List<ChatMessage>>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.activeConversation?.messages ?? [];
});

// Provider for conversation list
final conversationListProvider = Provider<List<ChatConversation>>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.conversations;
});

// Provider for special request templates
final specialRequestTemplatesProvider = Provider<List<String>>((ref) {
  return MockChatData.specialRequestTemplates;
});