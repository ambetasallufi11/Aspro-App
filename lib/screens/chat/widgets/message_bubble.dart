import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/chat_message.dart';
import '../../../providers/chat_provider.dart';

class MessageBubble extends ConsumerWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFromUser = message.isFromUser;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Row(
      mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isFromUser) _buildAvatar(context, ref),
        
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: EdgeInsets.only(
              left: isFromUser ? 64 : 8,
              right: isFromUser ? 8 : 64,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isFromUser 
                  ? primaryColor 
                  : theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isFromUser ? const Radius.circular(4) : null,
                bottomLeft: !isFromUser ? const Radius.circular(4) : null,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageContent(context),
                const SizedBox(height: 4),
                _buildTimestamp(context),
              ],
            ),
          ),
        ),
        
        if (isFromUser) _buildAvatar(context, ref),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSupport = ref.read(chatProvider).activeConversation?.isSupport ?? false;
    
    // For support chat, use the app logo
    if (!message.isFromUser && isSupport) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/aspro-logo.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.support_agent, 
                size: 20, 
                color: theme.colorScheme.primary,
              );
            },
          ),
        ),
      );
    }
    
    // For user avatar
    if (message.isFromUser) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.person, size: 20, color: theme.colorScheme.primary),
      );
    }
    
    // For merchant avatar
    return CircleAvatar(
      radius: 16,
      backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
      child: Icon(Icons.store, size: 20, color: theme.colorScheme.secondary),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    final isFromUser = message.isFromUser;
    
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: isFromUser 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurfaceVariant,
          ),
        );
        
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Add a background color while loading
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: isFromUser 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ),
                  // Attempt to load the image
                  Image.asset(
                    message.imageUrl ?? 'assets/aspro-logo.png', // Use app logo as fallback
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      // On error, show a nice error state
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_rounded, 
                              size: 48,
                              color: theme.colorScheme.error.withOpacity(0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.t('Image not available'),
                              style: TextStyle(
                                color: isFromUser 
                                    ? theme.colorScheme.onPrimary 
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
        
      case MessageType.specialRequest:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isFromUser 
                ? theme.colorScheme.primaryContainer.withOpacity(0.5) 
                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFromUser 
                  ? theme.colorScheme.primaryContainer 
                  : theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.request_page,
                    size: 16,
                    color: isFromUser 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.t('Special Request'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFromUser 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  color: isFromUser 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildTimestamp(BuildContext context) {
    final theme = Theme.of(context);
    final isFromUser = message.isFromUser;
    
    return Text(
      DateFormat('h:mm a').format(message.timestamp),
      style: TextStyle(
        fontSize: 10,
        color: isFromUser 
            ? theme.colorScheme.onPrimary.withOpacity(0.7) 
            : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
      ),
    );
  }
}
