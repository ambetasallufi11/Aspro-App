import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import 'widgets/chat_input.dart';
import 'widgets/message_bubble.dart';
import 'widgets/special_request_dialog.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? merchantId;

  const ChatScreen({
    super.key,
    this.merchantId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    ref.read(chatProvider.notifier).sendTextMessage(text);
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _sendImage() {
    // In a real app, this would open the image picker
    // For demo purposes, we'll just send a placeholder image
    ref.read(chatProvider.notifier).sendImageMessage('assets/sample_image.jpg');
    
    // Scroll to bottom after sending image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _showSpecialRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => SpecialRequestDialog(
        onRequestSelected: (request) {
          ref.read(chatProvider.notifier).sendSpecialRequest(request);
          
          // Scroll to bottom after sending special request
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeConversation = ref.watch(chatProvider).activeConversation;
    final messages = ref.watch(activeConversationMessagesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: activeConversation != null
            ? Text(activeConversation.merchantName)
            : Text(context.l10n.t('Chat')),
        elevation: 1,
      ),
      body: activeConversation == null
          ? Center(
              child: Text(
                context.l10n.t('No active conversation. Please select a merchant to chat with.'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text(
                            context.l10n.t('No messages yet. Start the conversation!'),
                          ),
                        )
                      : _buildMessageList(messages),
                ),
                ChatInput(
                  onSendMessage: _sendMessage,
                  onAttachImage: _sendImage,
                  onSpecialRequest: _showSpecialRequestDialog,
                ),
              ],
            ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    // Group messages by date
    final Map<String, List<ChatMessage>> groupedMessages = {};
    
    for (final message in messages) {
      final date = DateFormat(
        'MMMM d, yyyy',
        Localizations.localeOf(context).languageCode,
      ).format(message.timestamp);
      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    final sortedDates = groupedMessages.keys.toList()
      ..sort((a, b) => DateFormat(
            'MMMM d, yyyy',
            Localizations.localeOf(context).languageCode,
          )
          .parse(a)
          .compareTo(DateFormat(
            'MMMM d, yyyy',
            Localizations.localeOf(context).languageCode,
          ).parse(b)));

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        final dateMessages = groupedMessages[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            ...dateMessages.map((message) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MessageBubble(message: message),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
