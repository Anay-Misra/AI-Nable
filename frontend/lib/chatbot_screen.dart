import 'package:flutter/material.dart';
import 'api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _context = ''; // Store context from previous interactions

  @override
  void initState() {
    super.initState();
    _addBotMessage('Hi! Welcome to Tobi\'s Chatbot! Ask me anything about your educational content!');
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _textController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the context from previous interactions or a default context
      final context = _context.isNotEmpty ? _context : 'General educational content';
      
      final result = await ApiService.askQuestion(context, message);
      
      final answer = result['answer'] ?? 'I\'m not sure how to answer that.';
      _addBotMessage(answer);
      
      // Update context with the current conversation
      _context = 'Previous conversation: $message - $answer';
    } catch (e) {
      _addBotMessage('Sorry, I encountered an error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔙 Back + Logo Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFDE802F)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Image.asset('assets/logo.png', height: 40),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 12),

              // 🟠 Title
              const Text(
                'Snap Study',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDE802F),
                ),
              ),
              const Text(
                'Tobi Chatbot',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.orange,
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 20),

              // 💬 Chat Messages
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == 0) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/bear_learning.png', height: 30),
                              const SizedBox(width: 8),
                              const Text('Tobi is thinking...'),
                            ],
                          ),
                        );
                      }
                      
                      final messageIndex = _isLoading ? index - 1 : index;
                      final message = _messages[_messages.length - 1 - messageIndex];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser 
                              ? const Color(0xFFF19D47) 
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!message.isUser) ...[
                              Image.asset('assets/bear_learning.png', height: 30),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.isUser ? 'You' : 'Tobi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: message.isUser ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: message.isUser ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 👇 Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF19D47),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/bear_learning.png', height: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type your question here....',
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: Icon(
                        _isLoading ? Icons.hourglass_empty : Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}