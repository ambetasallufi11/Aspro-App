import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isFromUser = message.isFromUser;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Row(
      mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isFromUser) _buildAvatar(context),
        
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
        
        if (isFromUser) _buildAvatar(context),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    // In a real app, you would use the sender's avatar
    // For now, we'll use a placeholder
    return const CircleAvatar(
      radius: 16,
      child: Icon(Icons.person, size: 20),
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
              child: Image.asset(
                message.imageUrl ?? 'assets/placeholder.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    ),
                  );
                },
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
                    'Special Request',
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