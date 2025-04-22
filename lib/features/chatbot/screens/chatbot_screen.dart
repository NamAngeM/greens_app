import 'package:flutter/material.dart';
import '../models/chatbot_model.dart';
import '../services/chatbot_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/suggestion_chip.dart';
import '../../../common/widgets/app_loading_indicator.dart';
import '../../../common/widgets/error_view.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

  Future<void> _initializeChatbot() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _chatbotService.initialize();
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible d\'initialiser le chatbot: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _chatbotService.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi du message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSuggestionTap(String suggestion) {
    _sendMessage(suggestion);
  }

  Widget _buildChatList() {
    final activeSession = _chatbotService.activeSession;
    if (activeSession == null) {
      return const Center(
        child: Text('Aucune conversation active.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: activeSession.messages.length,
      itemBuilder: (context, index) {
        final message = activeSession.messages[index];
        final isUserMessage = message.sender == MessageSender.user;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: isUserMessage 
                ? CrossAxisAlignment.end 
                : CrossAxisAlignment.start,
            children: [
              ChatBubble(
                message: message,
                isUserMessage: isUserMessage,
              ),
              if (!isUserMessage && message.actionSuggestions != null && message.actionSuggestions!.isNotEmpty)
                _buildSuggestions(message.actionSuggestions!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions.map((suggestion) => 
          SuggestionChip(
            label: suggestion,
            onTap: () => _onSuggestionTap(suggestion),
          )
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoBot'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _initializeChatbot,
            tooltip: 'Redémarrer la conversation',
          ),
        ],
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: AppLoadingIndicator())
          : _errorMessage != null
              ? ErrorView(
                  message: _errorMessage!,
                  onRetry: _initializeChatbot,
                )
              : Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<EcobotSession>(
                        stream: _chatbotService.sessionStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !_isInitialized) {
                            return const Center(child: AppLoadingIndicator());
                          }
                          
                          return _buildChatList();
                        },
                      ),
                    ),
                    ChatInput(
                      onSend: _sendMessage,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 