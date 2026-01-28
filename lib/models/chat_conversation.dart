import 'chat_message.dart';
import 'laundry.dart';

class ChatConversation {
  final String id;
  final String userId;
  final String merchantId;
  final String merchantName;
  final String? merchantImageUrl;
  final List<ChatMessage> messages;
  final DateTime lastUpdated;
  final bool hasUnreadMessages;
  final bool isSupport;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.merchantName,
    this.merchantImageUrl,
    required this.messages,
    required this.lastUpdated,
    this.hasUnreadMessages = false,
    this.isSupport = false,
  });

  ChatConversation copyWith({
    String? id,
    String? userId,
    String? merchantId,
    String? merchantName,
    String? merchantImageUrl,
    List<ChatMessage>? messages,
    DateTime? lastUpdated,
    bool? hasUnreadMessages,
    bool? isSupport,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      merchantImageUrl: merchantImageUrl ?? this.merchantImageUrl,
      messages: messages ?? this.messages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      isSupport: isSupport ?? this.isSupport,
    );
  }

  // Helper method to get the last message in the conversation
  ChatMessage? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  // Helper method to get a preview of the last message content
  String get lastMessagePreview {
    final last = lastMessage;
    if (last == null) return '';
    
    switch (last.type) {
      case MessageType.text:
        return last.content.length > 30 
            ? '${last.content.substring(0, 30)}...' 
            : last.content;
      case MessageType.image:
        return '📷 Image';
      case MessageType.specialRequest:
        return '🔔 Special Request';
    }
  }

  // Create a conversation from a laundry
  factory ChatConversation.fromLaundry(Laundry laundry, String userId) {
    return ChatConversation(
      id: 'conv_${laundry.id}_$userId',
      userId: userId,
      merchantId: laundry.id,
      merchantName: laundry.name,
      merchantImageUrl: laundry.imageUrl,
      messages: [],
      lastUpdated: DateTime.now(),
      isSupport: false,
    );
  }
}