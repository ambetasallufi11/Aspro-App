import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/chat_conversation.dart';
import '../../providers/chat_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 1,
      ),
      body: conversations.isEmpty
          ? _buildEmptyState(context)
          : _buildConversationsList(context, conversations, ref),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with a merchant',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    BuildContext context,
    List<ChatConversation> conversations,
    WidgetRef ref,
  ) {
    // Sort conversations by last updated time (most recent first)
    final sortedConversations = [...conversations]
      ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedConversations.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conversation = sortedConversations[index];
        return _buildConversationTile(context, conversation, ref);
      },
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ChatConversation conversation,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.hasUnreadMessages;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: conversation.merchantImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  conversation.merchantImageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.store,
                color: theme.colorScheme.primary,
              ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.merchantName,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessage != null)
            Text(
              DateFormat.jm().format(lastMessage.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: hasUnread
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      subtitle: lastMessage != null
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.lastMessagePreview,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      color: hasUnread
                          ? theme.colorScheme.onBackground
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            )
          : null,
      onTap: () {
        // Set active conversation and navigate to chat screen
        ref.read(chatProvider.notifier).setActiveConversation(conversation.id);
        
        // Mark as read
        if (hasUnread) {
          ref.read(chatProvider.notifier).markConversationAsRead(conversation.id);
        }
        
        // Navigate to chat screen
        context.push('/chat');
      },
    );
  }
}