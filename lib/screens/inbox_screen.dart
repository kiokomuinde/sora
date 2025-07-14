// lib/screens/inbox_screen.dart
import 'package:flutter/material.dart';
import 'package:sora_app/services/auth_service.dart'; // Import AuthService
import 'package:sora_app/widgets/common_widgets.dart'; // Import CommonWidgets

class InboxScreen extends StatefulWidget {
  final AuthService authService;

  const InboxScreen({super.key, required this.authService});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  late CommonWidgets commonWidgets;
  // Dummy inbox messages
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Admin',
      'subject': 'Welcome to SORA Properties!',
      'body': 'Thank you for joining SORA Properties. We are excited to help you find your dream home!',
      'timestamp': '2025-07-10 10:00 AM',
      'read': false,
    },
    {
      'sender': 'Agent John Doe',
      'subject': 'Regarding your inquiry about ABC Villa',
      'body': 'Hi, I received your inquiry about ABC Villa. Let me know when you\'re available for a viewing.',
      'timestamp': '2025-07-09 03:30 PM',
      'read': false,
    },
    {
      'sender': 'System Notification',
      'subject': 'Your account has been updated',
      'body': 'Your profile information was successfully updated on 2025-07-08.',
      'timestamp': '2025-07-08 09:15 AM',
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    commonWidgets = CommonWidgets(context: context, authService: widget.authService);
  }

  void _markAsRead(int index) {
    setState(() {
      _messages[index]['read'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Message from ${_messages[index]['sender']} marked as read.')),
    );
  }

  void _deleteMessage(int index) {
    setState(() {
      final deletedMessage = _messages.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message from ${deletedMessage['sender']} deleted.'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                _messages.insert(index, deletedMessage);
              });
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth >= 1000;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 1000;

    return Scaffold(
      appBar: commonWidgets.buildAppBar(),
      endDrawer: commonWidgets.buildDrawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isLargeScreen ? 60 : (isMediumScreen ? 40 : 30),
              horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor.withOpacity(0.8), Theme.of(context).colorScheme.secondary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inbox',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 48 : (isMediumScreen ? 36 : 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your messages and notifications.',
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : (isMediumScreen ? 16 : 14),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Your inbox is empty.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 100 : (isMediumScreen ? 50 : 20),
                      vertical: 20,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: message['read'] ? Colors.white : Colors.blue.shade50,
                        child: ListTile(
                          leading: Icon(
                            message['read'] ? Icons.mail_outline : Icons.mail,
                            color: message['read'] ? Colors.grey : Theme.of(context).primaryColor,
                          ),
                          title: Text(
                            message['sender'],
                            style: TextStyle(
                              fontWeight: message['read'] ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['subject'],
                                style: TextStyle(
                                  fontWeight: message['read'] ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                message['body'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                message['timestamp'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Implement full message view
                            _markAsRead(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opening message from ${message['sender']}.')),
                            );
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDetailScreen(message: message)));
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMessage(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          commonWidgets.buildFooter(),
        ],
      ),
    );
  }
}