import 'package:flutter/material.dart';
import '../widgets/chat_widget.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat avec Llama'),
      ),
      body: const ChatWidget(),
    );
  }
} 