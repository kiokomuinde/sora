// lib/widgets/sora_ai_chat.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SoraAiChat extends StatefulWidget {
  const SoraAiChat({Key? key}) : super(key: key);

  @override
  _SoraAiChatState createState() => _SoraAiChatState();
}

class _SoraAiChatState extends State<SoraAiChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // This holds the memory of the conversation
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isLoading = false;

  // IMPORTANT: The exact Vercel URL you confirmed
  final String _vercelApiUrl = 'https://sora-ai-backend.vercel.app/api/chat';

  @override
  void initState() {
    super.initState();
    // The bot sends the first welcoming message!
    _chatHistory.add({
      "role": "model",
      "parts": [{"text": "Hello! I am Sora, your personal real estate assistant. Are you looking to buy, rent, or find a BNB today?"}]
    });
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      // Add user message to UI
      _chatHistory.add({
        "role": "user",
        "parts": [{"text": userText}]
      });
      _isLoading = true;
      _controller.clear();
    });
    
    _scrollToBottom();

    try {
      print("--- STEP 1: SENDING REQUEST TO VERCEL ---");
      print("Target URL: $_vercelApiUrl");
      print("Message sending: $userText");

      // ==========================================
      // THE FIX: Clean the history for Gemini
      // ==========================================
      List<Map<String, dynamic>> historyToSend = List.from(_chatHistory);
      historyToSend.removeLast(); // Don't send the current message in history
      
      // If the first message is our fake greeting, remove it so Gemini doesn't crash!
      if (historyToSend.isNotEmpty && historyToSend.first['role'] == 'model') {
        historyToSend.removeAt(0);
      }

      // Send the request to Vercel
      final response = await http.post(
        Uri.parse(_vercelApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': userText,
          'history': historyToSend // Send the cleaned history
        }),
      );

      print("--- STEP 2: VERCEL REPLIED ---");
      print("Status Code: ${response.statusCode}");
      print("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _chatHistory.add({
            "role": "model",
            "parts": [{"text": data['reply']}]
          });
        });
      } else {
        // If Vercel throws an error (like 500), we show the exact reason in the chat UI!
        final data = jsonDecode(response.body);
        final errorMessage = data['details'] ?? data['error'] ?? 'Unknown Server Error';
        _showError("Server Error ${response.statusCode}: $errorMessage");
      }
    } catch (e) {
      print("--- STEP 3: FLUTTER NETWORK CRASH ---");
      print("Exact Error: $e");
      _showError("App failed to reach the internet. Check your debug console.");
    } finally {
      setState(() { _isLoading = false; });
      _scrollToBottom();
    }
  }

  void _showError(String error) {
    setState(() {
      _chatHistory.add({
        "role": "model",
        "parts": [{"text": "Oops! $error"}]
      });
    });
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // Takes up 70% of screen
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0A66C2),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Chat with Sora AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          
          // Chat Messages Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                final isUser = message['role'] == 'user';
                final text = message['parts'][0]['text'];

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1E90FF) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                        bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),

          // Typing Input Area
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about properties...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF8C00),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}