import 'package:flutter/material.dart';
import '../models/chatbot_model.dart';
import '../../../common/styles/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUserMessage;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUserMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUserMessage 
            ? AppColors.primaryColor.withOpacity(0.9)
            : AppColors.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18).copyWith(
          bottomRight: isUserMessage ? const Radius.circular(4) : null,
          bottomLeft: !isUserMessage ? const Radius.circular(4) : null,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUserMessage) _buildBotAvatar(),
              if (!isUserMessage) const SizedBox(width: 8),
              Text(
                isUserMessage ? 'Vous' : 'EcoBot',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUserMessage ? Colors.white : AppColors.primaryColor,
                ),
              ),
              const Spacer(),
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: isUserMessage 
                      ? Colors.white.withOpacity(0.8)
                      : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message.content,
            style: TextStyle(
              color: isUserMessage ? Colors.white : Colors.black87,
              height: 1.4,
            ),
          ),
          if (message.isLoading && !isUserMessage)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 40,
                height: 10,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.secondaryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppColors.accentColor,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.eco_outlined,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day && 
        timestamp.month == now.month && 
        timestamp.year == now.year) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
} 