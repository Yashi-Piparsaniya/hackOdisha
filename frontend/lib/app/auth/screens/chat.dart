import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../common/themes/colors.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;

  // 🎤 Speech-to-Text
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // 🔊 Text-to-Speech
  late FlutterTts _flutterTts;

  static const String _apiUrl = "http://172.24.219.246:8000/predict"; // Change to your API

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      _controller.clear();
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 50));
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "symptoms": text.split(',').map((s) => s.trim()).toList(),
          "city": "Rourkela",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessage = """
Disease: ${data['disease'] ?? 'Unknown'}
Confidence: ${data['confidence']}%
Severity: ${data['severity']}
Specialist: ${data['specialist']}
Care Tips: ${data['care_tips']}
Hospitals: ${(data['nearby_hospitals'] as List).join(", ")}
""";

        setState(() => _messages.add({"text": botMessage, "isUser": false}));
        _scrollToBottom();
        await _flutterTts.speak(botMessage);
      } else {
        setState(() => _messages.add({
          "text": "⚠️ Error: ${response.statusCode}",
          "isUser": false,
        }));
      }
    } catch (e) {
      setState(() => _messages.add({
        "text": "❌ Failed to connect to server.",
        "isUser": false,
      }));
    }

    setState(() => _loading = false);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print("Status: $status"),
        onError: (error) => print("Error: $error"),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
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
            gradient: RadialGradient(
              colors: [
                AppColors.accent,
                AppColors.primary,
                AppColors.background
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message["isUser"];

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.accent
                              : AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isUser
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                message["text"],
                                style: TextStyle(
                                  color: isUser
                                      ? AppColors.text
                                      : AppColors.background,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (!isUser) ...[
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.volume_up,
                                    size: 20, color: Colors.white),
                                onPressed: () =>
                                    _flutterTts.speak(message["text"]),
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Enter or speak your symptoms...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _loading ? null : _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor:
                      _isListening ? Colors.green : Colors.redAccent,
                      child: IconButton(
                        icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: Colors.white),
                        onPressed: _toggleListening,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: IconButton(
                        icon: const Icon(Icons.stop, color: Colors.white),
                        onPressed: _stopSpeaking,
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
