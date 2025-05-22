import 'package:flutter/material.dart';
import 'package:greens_app/services/chatbot_service.dart';
import 'package:greens_app/models/chatbot_message.dart';
import 'package:greens_app/utils/app_theme.dart';

class ChatbotWidget extends StatefulWidget {
  final String userId;
  final Function(ChatbotAction)? onActionSelected;

  const ChatbotWidget({
    Key? key,
    required this.userId,
    this.onActionSelected,
  }) : super(key: key);

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatbotMessage> _messages = [];
  bool _isLoading = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _chatbotService.initialize();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final suggestions = await _chatbotService.getSuggestions();
    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _messageController.clear();
    });

    try {
      final response = await _chatbotService.sendMessageWithContext(
        message,
        userId: widget.userId,
      );

      setState(() {
        _messages.add(response);
        _isLoading = false;
      });

      // Charger de nouvelles suggestions après la réponse
      _loadSuggestions();

      // Faire défiler jusqu'au dernier message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _handleAction(ChatbotAction action) {
    if (widget.onActionSelected != null) {
      widget.onActionSelected!(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête du chat
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.eco, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assistant Écologique',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Je peux vous aider avec vos questions sur l\'écologie',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Zone des messages
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
        ),

        // Suggestions
        if (_suggestions.isNotEmpty)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(_suggestions[index]),
                    onPressed: () => _sendMessage(_suggestions[index]),
                  ),
                );
              },
            ),
          ),

        // Zone de saisie
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Posez votre question...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isLoading
                    ? null
                    : () => _sendMessage(_messageController.text),
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatbotMessage message) {
    final isUser = message.isUser;
    final hasActions = message.suggestedActions?.isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Actions suggérées
          if (hasActions)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestedActions!.map((action) {
                  return ActionChip(
                    label: Text(action),
                    onPressed: () => _sendMessage(action),
                  );
                }).toList(),
              ),
            ),

          // Actions contextuelles
          if (message.metadata != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.metadata!.entries.map((entry) {
                  if (entry.key.startsWith('action_')) {
                    final actionData = entry.value as Map<String, dynamic>;
                    return ActionChip(
                      label: Text(actionData['title']),
                      onPressed: () => _handleAction(
                        ChatbotAction(
                          type: ChatbotActionType.values.firstWhere(
                            (e) => e.toString() == actionData['type'],
                            orElse: () => ChatbotActionType.none,
                          ),
                          title: actionData['title'],
                          data: actionData['data'] ?? {},
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
} 