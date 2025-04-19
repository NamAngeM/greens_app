import 'package:flutter/material.dart';
import 'package:greens_app/services/rag_service.dart';
import 'package:greens_app/widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final RagService _ragService = RagService.instance;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isTyping = true);
    try {
      await _ragService.initialize();
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Bonjour ! Je suis votre assistant écologique. Comment puis-je vous aider aujourd'hui ?",
            isUserMessage: false,
          ),
        );
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Erreur lors de l'initialisation du service: $e",
            isUserMessage: false,
          ),
        );
        _isTyping = false;
      });
    }
  }
  
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String messageText = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: messageText,
        isUserMessage: true,
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final response = await _ragService.getResponse(messageText);
      
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUserMessage: false,
        ));
        _isTyping = false;
      });
      
      _scrollToBottom();
    } catch (error) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Désolé, une erreur s'est produite lors du traitement de votre demande: $error",
          isUserMessage: false,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }
  
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Écologique'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      _isTyping 
                          ? 'Initialisation...' 
                          : 'Envoyez un message pour commencer la conversation',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      return _messages[index];
                    },
                  ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assistant réfléchit...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Posez une question...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.green.shade700,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 