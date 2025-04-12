import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    this.isError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(context),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _getBubbleColor(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: _getTextColor(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return CircleAvatar(
      backgroundColor: isUser
          ? Theme.of(context).primaryColor
          : isError
              ? Colors.red
              : Colors.green,
      child: Icon(
        isUser
            ? Icons.person
            : isError
                ? Icons.error
                : Icons.eco,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Color _getBubbleColor(BuildContext context) {
    if (isUser) {
      return Theme.of(context).primaryColor.withOpacity(0.9);
    } else if (isError) {
      return Colors.red.shade100;
    } else {
      return Colors.green.shade100;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (isUser) {
      return Colors.white;
    } else {
      return Colors.black87;
    }
  }
} 