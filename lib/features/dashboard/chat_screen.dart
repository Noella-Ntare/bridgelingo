import 'package:bridgelingo/core/components/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'Muraho! I am your Kinyarwanda AI tutor. Ask me anything about the language!'},
  ];

  // Simple local responses for common Kinyarwanda questions
  String _getLocalResponse(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('hello') || lower.contains('muraho')) {
      return 'Muraho means "Hello" in Kinyarwanda! You can also say "Bite?" which means "How are you?"';
    } else if (lower.contains('thank') || lower.contains('murakoze')) {
      return '"Murakoze" means "Thank you" in Kinyarwanda. You can say "Murakoze cyane" for "Thank you very much"!';
    } else if (lower.contains('yes') || lower.contains('yego')) {
      return '"Yego" means "Yes" and "Oya" means "No" in Kinyarwanda.';
    } else if (lower.contains('bye') || lower.contains('goodbye')) {
      return 'You can say "Murabeho" (goodbye to many) or "Arabeho" (goodbye to one person) in Kinyarwanda.';
    } else if (lower.contains('name') || lower.contains('izina')) {
      return 'To ask someone\'s name say: "Witwa nde?" which means "What is your name?". To answer say "Nitwa [your name]".';
    } else if (lower.contains('water') || lower.contains('amazi')) {
      return '"Amazi" means water in Kinyarwanda. Staying hydrated is important — "Nywa amazi" means "Drink water"!';
    } else if (lower.contains('number') || lower.contains('count')) {
      return 'Numbers in Kinyarwanda: 1=Rimwe, 2=Kabiri, 3=Gatatu, 4=Kane, 5=Gatanu. Keep practicing!';
    } else if (lower.contains('color') || lower.contains('colour')) {
      return 'Colors: Red=Umutuku, Blue=Ubururu, Green=Icyatsi, White=Umweru, Black=Umukara.';
    } else {
      return 'Great question! Keep practicing your Kinyarwanda. Try asking me about greetings, numbers, colors, or common phrases!';
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate AI thinking
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _messages.add({'role': 'ai', 'content': _getLocalResponse(text)});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
      appBar: AppBar(
        title: const Text('AI Tutor'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text('Kinyarwanda'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(message['content']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Ask about Kinyarwanda...',
                    controller: _messageController,
                    icon: Icons.chat_bubble_outline,
                  ),
                ),
                const Gap(8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
