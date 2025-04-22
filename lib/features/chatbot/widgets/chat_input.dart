import 'package:flutter/material.dart';
import '../../../common/styles/app_colors.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;

  const ChatInput({
    Key? key,
    required this.onSendMessage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateSendButtonVisibility);
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateSendButtonVisibility);
    _messageController.dispose();
    super.dispose();
  }

  void _updateSendButtonVisibility() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (_showSendButton != hasText) {
      setState(() {
        _showSendButton = hasText;
      });
    }
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Posez une question sur l\'écologie...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabled: !widget.isLoading,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              keyboardType: TextInputType.text,
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: _showSendButton && !widget.isLoading ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: (_showSendButton && !widget.isLoading) ? _handleSendMessage : null,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: widget.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 