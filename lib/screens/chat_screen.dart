import 'package:flutter/material.dart';


import '../features/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUserMessage;
  ChatMessage({required this.text, required this.isUserMessage});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _messages.add(ChatMessage(
      text: "Namaste! Main Krishi Mitra hoon. Aapki kya sahayata kar sakta hoon?",
      isUserMessage: false,
    ));

  }

  void _handleSendPressed() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: text, isUserMessage: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final botReply = await _apiService.chatWithBot(text);
      setState(() {
        _messages.add(ChatMessage(text: botReply, isUserMessage: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Error: ${e.toString()}', isUserMessage: false));
      });
    } finally {
      setState(() { _isLoading = false; });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(alignment: Alignment.centerLeft, child: Text('Krishi Mitra is thinking...')),
            ),
          _buildTextInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUserMessage ? Colors.green[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(message.text, style: const TextStyle(fontSize: 16.0)),
      ),
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(offset: const Offset(0, -1), blurRadius: 2, color: Colors.black.withOpacity(0.1))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(hintText: 'Ask anything in English, हिंदी, or मराठी...'),
              onSubmitted: (_) => _handleSendPressed(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _handleSendPressed,
            color: Colors.green[700],
          ),
        ],
      ),
    );
  }
}