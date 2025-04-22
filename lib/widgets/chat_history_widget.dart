import 'package:flutter/material.dart';
import '../services/ollama_service.dart';

class ChatHistoryWidget extends StatefulWidget {
  final String conversationId;
  final Function()? onHistoryCleared;

  const ChatHistoryWidget({
    Key? key, 
    required this.conversationId,
    this.onHistoryCleared,
  }) : super(key: key);

  @override
  State<ChatHistoryWidget> createState() => _ChatHistoryWidgetState();
}

class _ChatHistoryWidgetState extends State<ChatHistoryWidget> {
  final _ollamaService = OllamaService.instance;
  
  @override
  Widget build(BuildContext context) {
    final history = _ollamaService.getConversationHistory(widget.conversationId);
    
    if (history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aucun historique disponible pour cette conversation.'),
        ),
      );
    }
    
    // Exclure le prompt système du début
    final displayHistory = history.length > 1 ? history.sublist(1) : history;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historique de la conversation', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Effacer l\'historique',
                onPressed: () {
                  _showClearHistoryDialog(context);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayHistory.length,
            itemBuilder: (context, index) {
              final message = displayHistory[index];
              final isUser = message['role'] == 'user';
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    isUser ? Icons.person_outline : Icons.eco_outlined,
                    color: isUser ? Colors.blue.shade700 : Colors.green.shade700,
                  ),
                  title: Text(
                    isUser ? 'Vous' : 'GreenBot',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUser ? Colors.blue.shade700 : Colors.green.shade700,
                    ),
                  ),
                  subtitle: Text(message['content'] ?? ''),
                  trailing: isUser ? 
                    IconButton(
                      icon: const Icon(Icons.replay),
                      tooltip: 'Poser à nouveau cette question',
                      onPressed: () {
                        Navigator.of(context).pop(message['content']);
                      }
                    ) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text('Êtes-vous sûr de vouloir effacer tout l\'historique de cette conversation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _ollamaService.clearConversationHistory(widget.conversationId);
              Navigator.of(context).pop();
              
              if (widget.onHistoryCleared != null) {
                widget.onHistoryCleared!();
              }
              
              setState(() {});
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }
} 