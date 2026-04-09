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

  // IMPORTANT: Your Vercel URL
  final String _vercelApiUrl = 'https://sora-ai-backend-amber.vercel.app/api/chat';

  @override
  void initState() {
    super.initState();
    // The bot sends the first welcoming message
    _chatHistory.add({
      "role": "model",
      "parts": [{
        "text": "Hello! I am Sora, your personal real estate assistant. Are you looking to buy, rent, or find a BNB today?",
        "imageUrl": null,
        "email": null,
        "phone": null // Added phone initialization
      }]
    });
  }

  Future<void> _sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _chatHistory.add({
        "role": "user",
        "parts": [{"text": userText}]
      });
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_vercelApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': userText,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _chatHistory.add({
            "role": "model",
            "parts": [{
              "text": data['replyText'] ?? "I found some information for you.",
              "imageUrl": data['imageUrl'],
              "email": data['email'],
              "phone": data['phone'] // Capturing the phone number from Vercel!
            }]
          });
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _chatHistory.add({
            "role": "model",
            "parts": [{"text": "Sorry, I'm having trouble connecting to the database right now. (Error ${response.statusCode})"}]
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _chatHistory.add({
          "role": "model",
          "parts": [{"text": "Network error. Please check your connection."}]
        });
        _isLoading = false;
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

  // Feature: Full Screen Image Viewer
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light, premium web background
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.real_estate_agent, color: Colors.white),
            SizedBox(width: 10),
            Text('Sora AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF0A66C2), // Sora Blue
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                final isUser = message['role'] == 'user';
                final parts = message['parts'][0];
                final text = parts['text'];
                final imageUrl = parts['imageUrl'];
                final email = parts['email'];
                final phone = parts['phone']; // Extract the new phone variable

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.65 : 0.85),
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0A66C2) : Colors.white,
                      boxShadow: isUser ? [] : [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(20),
                        bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. The Text (Includes pricing info from AI)
                          Text(
                            text,
                            style: TextStyle(
                              color: isUser ? Colors.white : const Color(0xFF2D3748), 
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                          
                          // 2. Premium Image Card
                          if (!isUser && imageUrl != null) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, imageUrl),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          height: 220,
                                          width: double.infinity,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => 
                                          Container(
                                            height: 150, 
                                            color: Colors.grey[200], 
                                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))
                                          ),
                                    ),
                                    Positioned(
                                      bottom: 0, left: 0, right: 0,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                                          )
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                          
                          // 3. Dynamic Action / Contact Buttons
                          if (!isUser && (email != null || phone != null)) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 12),
                            const Text("Contact Agent:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (phone != null)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: Text(phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      // Using SnackBar for testing. You can add url_launcher here later to actually dial!
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Calling $phone...')),
                                      );
                                    },
                                  ),
                                if (email != null)
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF8C00), // Sora Orange
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.email_outlined, size: 18),
                                    label: const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Emailing $email...')),
                                      );
                                    },
                                  ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Sleek Typing Indicator
          if (_isLoading)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 16, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 15, width: 15, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0A66C2))
                    ),
                    SizedBox(width: 10),
                    Text("Sora is searching properties...", style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),

          // Modern Typing Input Area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'e.g., Show me 2-bedroom BNBs...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A66C2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
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