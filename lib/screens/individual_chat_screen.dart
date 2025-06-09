```dart
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart'; // For current user context (conceptual)
import '../services/chat_service.dart';
import '../services/ai/on_device_ai_service.dart'; // Import AI service
import '../widgets/message_bubble.dart';
// import '../widgets/copilot_suggestion_bar.dart'; // Assuming this is created as a separate widget

// --- Conceptual CopilotSuggestionBar Widget (can be in a separate file) ---
class CopilotSuggestionBar extends StatelessWidget {
  final String suggestionText;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const CopilotSuggestionBar({
    Key? key,
    required this.suggestionText,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_outlined, size: 20.0, color: Theme.of(context).colorScheme.onSecondaryContainer),
          SizedBox(width: 10.0),
          Expanded(
            child: GestureDetector( // Use GestureDetector for tap on text area
              onTap: onTap,
              child: Text(
                suggestionText,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: Icon(Icons.close, size: 20.0),
            color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            tooltip: "Dismiss suggestion",
          ),
        ],
      ),
    );
  }
}
// --- End Conceptual CopilotSuggestionBar Widget ---


class IndividualChatScreen extends StatefulWidget {
  final String chatId;
  final String chatParticipantName;
  // final UserModel chatParticipant; // Alternative

  IndividualChatScreen({
    Key? key,
    required this.chatId,
    required this.chatParticipantName,
    // required this.chatParticipant,
  }) : super(key: key);

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final OnDeviceAiService _aiService = OnDeviceAiService(); // AI Service instance
  List<ChatMessageModel> _messages = [];
  bool _isLoadingMessages = true;
  final String _currentUserId = 'currentUser123';

  Stream<ChatMessageModel>? _messageStream;

  // Copilot State
  String? _currentCopilotSuggestion;
  bool _copilotEnabledForThisChat = true; // Conceptual: Assume true for now
  // Map<String, String> _participantDisplayNames = {}; // For group chat sender names - conceptual

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenToMessages(); // Listens to messages from ChatService (backend)
    _messageController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    // If user starts typing, dismiss Copilot suggestion
    if (_messageController.text.isNotEmpty && _currentCopilotSuggestion != null) {
      setState(() {
        _currentCopilotSuggestion = null;
      });
    }
  }

  Future<void> _checkForCopilotSuggestion(ChatMessageModel incomingMessage) async {
    if (_copilotEnabledForThisChat && incomingMessage.senderId != _currentUserId) {
      // String senderName = _participantDisplayNames[incomingMessage.senderId] ?? widget.chatParticipantName; // More robust name fetching needed
      String senderName = widget.chatParticipantName; // Simplified for 1-on-1

      final suggestion = await _aiService.getCopilotSuggestion(incomingMessage.text, senderName);
      if (mounted && suggestion != null) { // Check if widget is still in tree
        setState(() {
          _currentCopilotSuggestion = suggestion;
        });
      }
    }
  }

  void _loadMessages() async {
    // ... (existing message loading logic from previous subtask) ...
    // For testing Copilot, let's add a dummy received message
    // if (_messages.isEmpty && widget.chatId == "friend_user_id_1") { // Simulate specific chat
    //   ChatMessageModel initialFriendMessage = ChatMessageModel(messageId: 'initmsg', senderId: widget.chatId, threadId: widget.chatId, text: 'Hey, got a question for you.', timestamp: DateTime.now().subtract(Duration(seconds:10)), type: MessageType.text);
    //   _messages.insert(0, initialFriendMessage);
    //   _checkForCopilotSuggestion(initialFriendMessage);
    // }
    // ...
    setState(() { _isLoadingMessages = true; });
    try {
      final messages = await _chatService.getMessages(widget.chatId);
      if(mounted){
        setState(() {
          _messages = messages.reversed.toList();
          _isLoadingMessages = false;
          // If there's an initial message from the other user, check for suggestion
          if (_messages.isNotEmpty && _messages.first.senderId != _currentUserId) {
            _checkForCopilotSuggestion(_messages.first);
          }
        });
      }
    } catch (e) { /* ... error handling ... */ }
  }

  void _listenToMessages() {
    _messageStream = _chatService.getMessageStream(widget.chatId);
    _messageStream?.listen((newMessage) {
      if(mounted){
        setState(() {
          _messages.insert(0, newMessage);
        });
        // Check for Copilot suggestion when a new message arrives
        _checkForCopilotSuggestion(newMessage);
      }
    }, onError: (error) { /* ... error handling ... */ });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }
    final text = _messageController.text.trim();

    // Clear suggestion when user sends a message
    if (_currentCopilotSuggestion != null) {
      setState(() { _currentCopilotSuggestion = null; });
    }
    _messageController.clear();

    final newMessage = ChatMessageModel( /* ... create message ... */
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      threadId: widget.chatId,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    // Optimistic UI update (or rely on stream echo)
    // setState(() { _messages.insert(0, newMessage); });

    try {
      await _chatService.sendMessage(widget.chatId, newMessage);
    } catch (e) { /* ... error handling, potentially remove optimistic message ... */ }
  }

  void _useCopilotSuggestion() {
    if (_currentCopilotSuggestion != null) {
      _messageController.text = _currentCopilotSuggestion!;
      _messageController.selection = TextSelection.fromPosition(TextPosition(offset: _messageController.text.length)); // Move cursor to end
      setState(() {
        _currentCopilotSuggestion = null; // Clear suggestion after use
      });
    }
  }

  void _dismissCopilotSuggestion() {
    setState(() {
      _currentCopilotSuggestion = null;
    });
  }


  @override
  void dispose() {
    _messageController.removeListener(_onInputChanged);
    _messageController.dispose();
    _chatService.disposeStreamController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatParticipantName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _isLoadingMessages
                ? Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(child: Text('No messages yet. Say hi!'))
                    : ListView.builder( /* ... existing ListView.builder ... */
                        reverse: true,
                        padding: EdgeInsets.all(8.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == _currentUserId,
                            // Potentially pass sender name for group chats
                          );
                        },
                      ),
          ),
          // Copilot Suggestion Bar Display
          if (_currentCopilotSuggestion != null)
            CopilotSuggestionBar(
              suggestionText: _currentCopilotSuggestion!,
              onTap: _useCopilotSuggestion,
              onDismiss: _dismissCopilotSuggestion,
            ),

          Padding( // Message Input Area
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: MediaQuery.of(context).padding.bottom + 8.0, top: 4.0),
            child: Row( /* ... existing input Row ... */
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
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
