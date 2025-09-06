import 'package:flutter/material.dart';
import '../../common/themes/colors.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello! How are you feeling?", "isUser": false},
    {"text": "I have a headache.", "isUser": true},
    {"text": "Hello! How are you feeling?", "isUser": false},
    {"text": "I have a headache.", "isUser": true},
    {"text": "Hello! How are you feeling?", "isUser": false},
    {"text": "I have a headache.", "isUser": true},
    {"text": "Hello! How are you feeling?", "isUser": false},
    {"text": "I have a headache.", "isUser": true},
    {"text": "Hello! How are you feeling?", "isUser": false},
    {"text": "I have a headache.", "isUser": true},
    {"text": "Hello! How are you feeling?", "isUser": false},
    {"text": "I have a headache.", "isUser": true},
    {"text": "Hello! How are you feeling?", "isUser": false},
    {"text": "I have a headache.", "isUser": true},
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({"text": text, "isUser": true});
      });
      _controller.clear();

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({"text": "I understand. How long have you had it?", "isUser": false});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SwasthAI",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [AppColors.accent, AppColors.primary ,AppColors.background])
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message["isUser"]
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: message["isUser"]
                              ? AppColors.accent
                              : AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: message["isUser"]
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: message["isUser"]
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message["text"],
                          style: TextStyle(
                              color: message["isUser"]
                                  ? AppColors.text
                                  : AppColors.background,
                              fontSize: 15
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Input field with send & voice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    // Input field
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Enter message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Send button
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Voice button
                    CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: IconButton(
                        icon: const Icon(Icons.mic, color: Colors.white),
                        onPressed: () {

                        },
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
}
