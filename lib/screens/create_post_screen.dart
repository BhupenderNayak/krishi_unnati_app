import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  bool _isPosting = false;


  Future<void> _submitPost() async {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    setState(() { _isPosting = true; });


    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post submitted successfully! (Demo)'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        backgroundColor: Colors.green[700],
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isPosting
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : TextButton(
              onPressed: _submitPost,
              child: const Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration.collapsed(
            hintText: 'Aapke mann mein kya hai?',
          ),
          maxLines: null,
        ),
      ),
    );
  }
}