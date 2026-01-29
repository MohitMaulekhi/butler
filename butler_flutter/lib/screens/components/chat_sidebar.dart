import 'package:butler_client/butler_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatSidebar extends StatelessWidget {
  final List<ChatSession> sessions;
  final int? selectedSessionId;
  final Function(ChatSession) onSessionSelected;
  final VoidCallback onNewChat;
  final Function(ChatSession) onDeleteSession;

  const ChatSidebar({
    super.key,
    required this.sessions,
    required this.selectedSessionId,
    required this.onSessionSelected,
    required this.onNewChat,
    required this.onDeleteSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onNewChat,
                icon: const Icon(Icons.add),
                label: const Text('New Chat'),
                style: FilledButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // Session List
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isSelected = session.id == selectedSessionId;
                final dateStr = DateFormat(
                  'MM/dd HH:mm',
                ).format(session.updatedAt);

                return ListTile(
                  title: Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    dateStr,
                    style: theme.textTheme.bodySmall,
                  ),
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  onTap: () => onSessionSelected(session),
                  trailing: isSelected
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => onDeleteSession(session),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
