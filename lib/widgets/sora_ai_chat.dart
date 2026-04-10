// lib/widgets/sora_ai_chat.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; 

class SoraAiChat extends StatefulWidget {
  const SoraAiChat({Key? key}) : super(key: key);

  @override
  _SoraAiChatState createState() => _SoraAiChatState();
}

class _SoraAiChatState extends State<SoraAiChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isLoading = false;

  final String _vercelApiUrl = 'https://sora-ai-backend-amber.vercel.app/api/chat';

  @override
  void initState() {
    super.initState();
    _chatHistory.add({
      "role": "model",
      "parts": [{
        "text": "Hello! I am Sora, your personal real estate assistant. Are you looking to buy, rent, or find a BNB today?",
        "imageGallery": null, 
        "email": null,
        "phone": null 
      }]
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.add({
        "role": "user",
        "parts": [{"text": text, "imageGallery": null, "email": null, "phone": null}]
      });
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_vercelApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<String>? galleryList;
        if (data['imageGallery'] != null) {
          galleryList = (data['imageGallery'] as List).map((item) => item.toString()).toList();
        }

        setState(() {
          _chatHistory.add({
            "role": "model",
            "parts": [{
              "text": data['replyText'] ?? "Here is what I found.",
              "imageGallery": galleryList, 
              "email": data['email'],
              "phone": data['phone'],
            }]
          });
        });
      } else {
        _addErrorToChat();
      }
    } catch (e) {
      _addErrorToChat();
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _addErrorToChat() {
    setState(() {
      _chatHistory.add({
        "role": "model",
        "parts": [{
          "text": "Oops! I encountered a network error connecting to the server. Please try again.",
          "imageGallery": null,
          "email": null,
          "phone": null
        }]
      });
    });
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

  // ====================================================================
  // BOTTOM SHEETS
  // ====================================================================
  void _showContactOptions(BuildContext context, String phone, bool isCompanyContact) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text("How would you like to connect?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Primary Phone Call
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.phone, color: Colors.white)),
                  title: Text(isCompanyContact ? "Call Sora Properties (Primary)" : "Call Agent"),
                  subtitle: Text(phone),
                  onTap: () async {
                    Navigator.pop(context); 
                    final Uri launchUri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
                    else _showErrorSnackBar("Could not open the phone dialer.");
                  },
                ),

                // Secondary Phone Call (Only shows for the company)
                if (isCompanyContact)
                  ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.lightBlue, child: Icon(Icons.phone, color: Colors.white)),
                    title: const Text("Call Sora Properties (Secondary)"),
                    subtitle: const Text("0712529637"),
                    onTap: () async {
                      Navigator.pop(context); 
                      final Uri launchUri = Uri(scheme: 'tel', path: "0712529637");
                      if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
                      else _showErrorSnackBar("Could not open the phone dialer.");
                    },
                  ),
                
                // WhatsApp
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.message, color: Colors.white)),
                  title: Text(isCompanyContact ? "WhatsApp Sora Properties" : "WhatsApp Agent"),
                  subtitle: const Text("Send a quick message"),
                  onTap: () async {
                    Navigator.pop(context); 
                    
                    String formattedPhone = phone.replaceAll(RegExp(r'\s+'), '');
                    if (formattedPhone.startsWith('0')) formattedPhone = '254${formattedPhone.substring(1)}';
                    else if (formattedPhone.startsWith('+')) formattedPhone = formattedPhone.substring(1);

                    String customMessage = isCompanyContact
                        ? "Hello! I am reaching out to Sora Properties. I need help finding a property that matches my needs."
                        : "Hello! I am interested in a property I found via the Sora AI Assistant. Could you provide more details?";
                    
                    String encodedMessage = Uri.encodeComponent(customMessage);
                    final Uri launchUri = Uri.parse("https://wa.me/$formattedPhone?text=$encodedMessage");
                    
                    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                    else _showErrorSnackBar("Could not open WhatsApp.");
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showEmailOptions(BuildContext context, String email, bool isCompanyContact) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        String rawSubject = isCompanyContact ? "General Inquiry via Sora AI" : "Inquiry about a property from Sora AI Assistant";
        String encodedSubject = Uri.encodeComponent(rawSubject);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text("Choose an Email App", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.mail, color: Colors.white)),
                  title: const Text("Default Mail App"), subtitle: const Text("Opens your phone's email app"),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri launchUri = Uri.parse("mailto:$email?subject=$encodedSubject");
                    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
                    else _showErrorSnackBar("Could not open your mail app.");
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.g_mobiledata, color: Colors.white, size: 36)),
                  title: const Text("Gmail (Browser)"), subtitle: const Text("Compose directly in Gmail"),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri launchUri = Uri.parse("https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$encodedSubject");
                    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                    else _showErrorSnackBar("Could not open Gmail.");
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.alternate_email, color: Colors.white)),
                  title: const Text("Yahoo Mail (Browser)"), subtitle: const Text("Compose directly in Yahoo"),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri launchUri = Uri.parse("https://compose.mail.yahoo.com/?to=$email&subject=$encodedSubject");
                    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                    else _showErrorSnackBar("Could not open Yahoo.");
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.copy, color: Colors.white)),
                  title: const Text("Copy Email Address"), subtitle: Text(email),
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: email));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email address copied to clipboard!"), backgroundColor: Colors.green));
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ====================================================================
  // UI RENDERING
  // ====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sora AI Assistant', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                final isModel = message["role"] == "model";
                final parts = message["parts"][0];

                return _buildMessageBubble(
                  isModel: isModel,
                  text: parts["text"],
                  imageGallery: parts["imageGallery"], 
                  email: parts["email"],
                  phone: parts["phone"],
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isModel,
    required String text,
    List<String>? imageGallery,
    String? email,
    String? phone,
  }) {
    // Corrected to seamlessly identify both company phone numbers
    bool isCompanyContact = (email == 'sales@soraproperties.co.ke' || phone == '0702778897' || phone == '0712529637');

    return Align(
      alignment: isModel ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85), // Made slightly wider for better images
        decoration: BoxDecoration(
          color: isModel ? Colors.grey[100] : const Color(0xFF0A66C2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isModel ? const Radius.circular(0) : const Radius.circular(16),
            bottomRight: isModel ? const Radius.circular(16) : const Radius.circular(0),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isModel ? Colors.black87 : Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            
            // RENDERING THE PREMIUM LISTING CAROUSEL
            if (imageGallery != null && imageGallery.isNotEmpty) ...[
              const SizedBox(height: 16),
              _ListingImageCarousel(images: imageGallery), 
            ],

            if (isModel && (email != null || phone != null)) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (phone != null)
                    ElevatedButton.icon(
                      onPressed: () => _showContactOptions(context, phone, isCompanyContact),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.phone, size: 18),
                      label: Text(isCompanyContact ? "Contact Sora" : "Contact Agent"),
                    ),
                  if (email != null)
                    ElevatedButton.icon(
                      onPressed: () => _showEmailOptions(context, email, isCompanyContact),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.email, size: 18),
                      label: const Text("Email"),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: const BoxDecoration(color: Color(0xFF0A66C2), shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white, size: 24), onPressed: _sendMessage),
          )
        ],
      ),
    );
  }
}

// ====================================================================
// PREMIUM PROPERTY LISTING CAROUSEL WIDGET
// ====================================================================
class _ListingImageCarousel extends StatefulWidget {
  final List<String> images;
  const _ListingImageCarousel({Key? key, required this.images}) : super(key: key);

  @override
  __ListingImageCarouselState createState() => __ListingImageCarouselState();
}

class __ListingImageCarouselState extends State<_ListingImageCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 16 / 10, // Creates that perfect real estate wide-angle look
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 1. The Image Pager
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // Adds a subtle loading spinner for each image
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          color: const Color(0xFF0A66C2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                );
              },
            ),
            
            // 2. The Premium Image Counter Chip (Top Right)
            if (widget.images.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // 3. Left Arrow Overlay
            if (_currentIndex > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    radius: 14,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                      onPressed: () {
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                    ),
                  ),
                ),
              ),
              
            // 4. Right Arrow Overlay
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    radius: 14,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                      onPressed: () {
                        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                    ),
                  ),
                ),
              ),
              
            // 5. The Animated Dot Overlay (Bottom)
            if (widget.images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      // Makes the active dot slightly wider for a modern feel
                      width: _currentIndex == index ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}