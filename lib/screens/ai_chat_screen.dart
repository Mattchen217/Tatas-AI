```dart
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart'; // Reusing for consistency
import '../widgets/message_bubble.dart';
import '../services/ai/on_device_ai_service.dart'; // Correct path

class AiChatScreen extends StatefulWidget {
  // Optional: Pass AI personality/name if customizable
  final String aiDisplayName;

  AiChatScreen({Key? key, this.aiDisplayName = "Personal AI"}) : super(key: key);

  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final OnDeviceAiService _aiService = OnDeviceAiService(); // Instantiated
  final List<ChatMessageModel> _messages = []; // State variable for messages
  bool _isAiTyping = false;

  // Define consistent sender IDs
  static const String _currentUserId = 'user_self_chatting_with_ai'; // User's ID in AI chat context
  static const String _aiId = 'personal_ai_assistant_id';         // AI's ID

  @override
  void initState() {
    super.initState();
    // Optional: Add an initial greeting from the AI
    _addMessageToUi(ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _aiId,
      threadId: 'local_ai_chat', // Conceptual threadId for local AI chat
      text: 'Hello! I am ${widget.aiDisplayName}. How can I help you today?',
      timestamp: DateTime.now(),
      type: MessageType.text,
    ), isAiMessage: true);
  }

  // Helper to add message to UI and manage list order
  void _addMessageToUi(ChatMessageModel message, {bool isAiMessage = false}) {
    setState(() {
      _messages.insert(0, message); // Add to start for reversed list display
    });
  }

  Future<void> _handleUserMessageSubmission() async {
    final userInputText = _messageController.text.trim();
    if (userInputText.isEmpty) {
      return;
    }

    // 1. Create user's message and add to UI
    final userMessage = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      threadId: 'local_ai_chat',
      text: userInputText,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    _addMessageToUi(userMessage);

    _messageController.clear(); // Clear input field

    // 2. Show AI typing indicator
    setState(() {
      _isAiTyping = true;
    });

    // 3. Get AI response
    try {
      final aiResponseText = await _aiService.getResponse(userInputText);

      // 4. Create AI's message and add to UI
      final aiMessage = ChatMessageModel(
        messageId: (DateTime.now().millisecondsSinceEpoch + 1).toString(), // Ensure unique ID
        senderId: _aiId,
        threadId: 'local_ai_chat',
        text: aiResponseText,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      _addMessageToUi(aiMessage, isAiMessage: true);

    } catch (e) {
      // Handle error in AI response
      final errorMessage = ChatMessageModel(
        messageId: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        senderId: _aiId,
        threadId: 'local_ai_chat',
        text: "Sorry, I encountered an issue. Please try again.",
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      _addMessageToUi(errorMessage, isAiMessage: true);
      print("Error getting AI response: $e");
    } finally {
      // 5. Remove AI typing indicator
      setState(() {
        _isAiTyping = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aiDisplayName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text('Ask your AI anything!'))
                : ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        message: message,
                        isCurrentUser: message.senderId == _currentUserId,
                        // senderDisplayName: message.senderId == _aiId ? widget.aiDisplayName : null, // Optional: Pass AI name to bubble
                      );
                    },
                  ),
          ),
          if (_isAiTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2.0),
                  SizedBox(width: 10.0),
                  Text("${widget.aiDisplayName} is thinking..."),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: MediaQuery.of(context).padding.bottom + 8.0, top: 4.0), // Adjust for keyboard/notch
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message ${widget.aiDisplayName}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _isAiTyping ? null : (_) => _handleUserMessageSubmission(),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send_rounded),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: _isAiTyping ? null : _handleUserMessageSubmission,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```
