```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../models/chat_message_model.dart';
import '../models/user_model.dart'; // For chat partner details if passed as UserModel
import '../services/chat_service.dart';
import '../services/ai/on_device_ai_service.dart';
// import '../services/chat_settings_service.dart'; // Conceptual for saving AI settings
import '../widgets/message_bubble.dart';
// import '../widgets/chat_input_bar.dart'; // To be defined in 1.6
// import './chat_thread_settings_screen.dart'; // For chat-specific settings

// --- Conceptual ChatSettingsService (from Subtask "Define the conceptual UI controls for enabling/disabling Autopilot") ---
// Can be moved to its own file: lib/services/chat_settings_service.dart
class ChatSettingsService {
  Future<Map<String, bool>> getAiSettings(String threadId, String userId) async {
    print('ChatSettingsService: Fetching AI settings for thread $threadId, user $userId');
    await Future.delayed(Duration(milliseconds: 150));
    // Simulate fetching. In a real app, this comes from a persistent store / backend.
    // Return default values if not found for this conceptual task.
    return {'copilotEnabled': true, 'autopilotEnabled': false};
  }

  Future<bool> updateAiSettings(String threadId, String userId, {bool? copilotEnabled, bool? autopilotEnabled}) async {
    print('ChatSettingsService: Updating AI settings for thread $threadId, user $userId: Copilot=$copilotEnabled, Autopilot=$autopilotEnabled');
    await Future.delayed(Duration(milliseconds: 300));
    // Conceptual: Make API call to backend: PUT /api/chat/threads/:threadId/ai-settings
    // Body: { userId: "...", settings: { "copilotEnabled": copilotEnabled, "autopilotEnabled": autopilotEnabled ... } }
    return true; // Simulate success
  }
}
// --- End Conceptual ChatSettingsService ---


// --- Conceptual ChatInputBar Widget (placeholder for Subtask 1.6) ---
// This would be in lib/widgets/chat_input_bar.dart
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachPressed; // Conceptual

  const ChatInputBar({
    Key? key,
    required this.controller,
    required this.onSendPressed,
    required this.onAttachPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: MediaQuery.of(context).padding.bottom + 8.0, top: 8.0),
      color: Theme.of(context).cardColor, // Or specific background color
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_photo_alternate_outlined),
            onPressed: onAttachPressed,
            tooltip: "Attach media",
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor, // Contrasting color
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSendPressed(),
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: Icon(Icons.send_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: onSendPressed,
            tooltip: "Send message",
          ),
        ],
      ),
    );
  }
}
// --- End Conceptual ChatInputBar Widget ---


class IndividualChatScreen extends StatefulWidget { // Renamed from IndividualChatPage for consistency
  final String chatId;
  final String chatParticipantName;
  final String? chatParticipantAvatarUrl; // Optional
  final Color? chatParticipantAvatarColor; // Optional, for initial letter avatar

  const IndividualChatScreen({
    Key? key,
    required this.chatId,
    required this.chatParticipantName,
    this.chatParticipantAvatarUrl,
    this.chatParticipantAvatarColor,
  }) : super(key: key);

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final OnDeviceAiService _aiService = OnDeviceAiService();
  final ChatSettingsService _chatSettingsService = ChatSettingsService(); // Conceptual

  List<ChatMessageModel> _messages = [];
  bool _isLoadingMessages = true;
  bool _isSendingMessage = false; // To disable send button during send

  // AI Feature States
  bool _copilotEnabled = true; // Default, will be loaded
  bool _autopilotEnabled = false; // Default, will be loaded
  List<String> _copilotSuggestions = [];
  bool _isGeneratingCopilotSuggestions = false;

  // Conceptual: Current user ID, would come from an AuthService
  final String _currentUserId = 'currentUser123';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _messageController.addListener(_onInputChanged);
  }

  Future<void> _loadInitialData() async {
    setState(() { _isLoadingMessages = true; });
    try {
      // Fetch initial messages
      final messages = await _chatService.getMessages(widget.chatId);
      // Fetch AI settings for this chat
      final aiSettings = await _chatSettingsService.getAiSettings(widget.chatId, _currentUserId);

      if (mounted) {
        setState(() {
          _messages = messages.reversed.toList();
          _copilotEnabled = aiSettings['copilotEnabled'] ?? true;
          _autopilotEnabled = aiSettings['autopilotEnabled'] ?? false;
          _isLoadingMessages = false;
        });
        // If there's an initial message from the other user, check for suggestion
        if (_messages.isNotEmpty && _messages.first.senderId != _currentUserId) {
          _triggerCopilotSuggestion(_messages.first);
        }
      }
    } catch (e) {
      if (mounted) setState(() { _isLoadingMessages = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load chat: $e')));
    }
    // TODO: Setup stream listener for new messages from _chatService.getMessageStream()
    // This was in previous conceptual code and should be re-added here.
    // _chatService.getMessageStream(widget.chatId).listen((newMessage) {
    //   if (mounted) {
    //     setState(() { _messages.insert(0, newMessage); });
    //     _triggerCopilotSuggestion(newMessage);
    //   }
    // });
  }

  void _onInputChanged() {
    if (_messageController.text.isNotEmpty && _copilotSuggestions.isNotEmpty) {
      setState(() { _copilotSuggestions = []; }); // Clear suggestions when user types
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSendingMessage = true;
      _copilotSuggestions = []; // Clear suggestions on send
    });
    _messageController.clear();

    final newMessage = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(), // Temp client ID
      senderId: _currentUserId,
      threadId: widget.chatId,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    // Optimistic UI update (or rely on stream echo from ChatService)
    // setState(() { _messages.insert(0, newMessage); });

    try {
      await _chatService.sendMessage(widget.chatId, newMessage);
      // If not using stream echo for own messages, add it here after successful send
    } catch (e) {
      // Handle send error, e.g., show error, add message back to input, mark as unsent
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message.')));
      // setState(() { _messages.remove(newMessage); }); // If optimistic update was done
    } finally {
      if (mounted) setState(() { _isSendingMessage = false; });
    }
  }

  Future<void> _triggerCopilotSuggestion(ChatMessageModel incomingMessage) async {
    if (_copilotEnabled && incomingMessage.senderId != _currentUserId) {
      if (mounted) setState(() { _isGeneratingCopilotSuggestions = true; });
      try {
        final suggestion = await _aiService.getCopilotSuggestion(
          incomingMessage.text,
          widget.chatParticipantName // Pass participant's name
        );
        if (mounted && suggestion != null) {
          setState(() {
            _copilotSuggestions = [suggestion]; // For now, handle one suggestion. Could be List<String>
          });
        }
      } catch (e) {
        print("Error getting Copilot suggestion: $e");
      } finally {
        if (mounted) setState(() { _isGeneratingCopilotSuggestions = false; });
      }
    }
  }

  void _useCopilotSuggestion(String suggestion) {
    _messageController.text = suggestion;
    _messageController.selection = TextSelection.fromPosition(TextPosition(offset: _messageController.text.length));
    setState(() { _copilotSuggestions = []; });
  }

  void _showChatSettings() {
    // Placeholder: In a real app, navigate to a proper ChatThreadSettingsScreen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatThreadSettingsScreen(threadId: widget.chatId, chatTitle: widget.chatParticipantName)));

    // For this conceptual step, show a modal bottom sheet with toggles
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to update toggles within the sheet
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Wrap(
                children: <Widget>[
                  Text("AI Settings for this Chat", style: Theme.of(context).textTheme.titleLarge),
                  SwitchListTile(
                    title: Text('Enable Copilot'),
                    subtitle: Text('Get AI reply suggestions.'),
                    value: _copilotEnabled,
                    onChanged: (bool value) async {
                      setSheetState(() { _copilotEnabled = value; });
                      setState(() { _copilotEnabled = value; }); // Update screen state too
                      await _chatSettingsService.updateAiSettings(widget.chatId, _currentUserId, copilotEnabled: value);
                      if (!value) setState(() => _copilotSuggestions = [] ); // Clear suggestions if disabled
                    },
                  ),
                  SwitchListTile(
                    title: Text('Enable Autopilot'),
                    subtitle: Text('Allow AI to reply automatically (use with caution).'),
                    value: _autopilotEnabled,
                    onChanged: (bool value) async {
                       setSheetState(() { _autopilotEnabled = value; });
                       setState(() { _autopilotEnabled = value; }); // Update screen state too
                       await _chatSettingsService.updateAiSettings(widget.chatId, _currentUserId, autopilotEnabled: value);
                    },
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Helper to group messages by date for adding dividers
  List<dynamic> _getMessagesWithDateDividers() {
    List<dynamic> items = [];
    DateTime? lastDate;
    for (var i = _messages.length - 1; i >= 0; i--) { // Iterate from oldest to newest for divider logic
      final message = _messages[i];
      final messageDate = DateTime(message.timestamp.year, message.timestamp.month, message.timestamp.day);
      if (lastDate == null || !isSameDay(lastDate, messageDate)) {
        items.add(messageDate); // Add date as a divider item
        lastDate = messageDate;
      }
      items.add(message); // Add message item
    }
    return items.reversed.toList(); // Reverse again to have newest at bottom for ListView (if ListView not reversed)
                                   // Or keep as is if ListView is reversed. Current ListView is reversed.
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  void dispose() {
    _messageController.removeListener(_onInputChanged);
    _messageController.dispose();
    // _chatService.disposeStreamController(); // If stream is managed by ChatService
    super.dispose();
  }

  Widget _buildDateDivider(DateTime date) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          DateFormat.yMMMd().format(date), // e.g., Oct 28, 2023
          style: TextStyle(fontSize: 12.0, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final processedMessageList = _getMessagesWithDateDividers();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.chatParticipantAvatarColor ?? Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: widget.chatParticipantAvatarUrl != null ? NetworkImage(widget.chatParticipantAvatarUrl!) : null,
              child: (widget.chatParticipantAvatarUrl == null && widget.chatParticipantName.isNotEmpty)
                  ? Text(widget.chatParticipantName[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer))
                  : null,
            ),
            SizedBox(width: 10),
            Text(widget.chatParticipantName),
          ],
        ),
        actions: [
          // Placeholder for Call buttons if needed
          // IconButton(icon: Icon(Icons.videocam_outlined), onPressed: () {}),
          // IconButton(icon: Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: _showChatSettings,
            tooltip: "Chat Settings",
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _isLoadingMessages
                ? Center(child: CircularProgressIndicator())
                : processedMessageList.isEmpty
                    ? Center(child: Text('No messages yet. Start the conversation!'))
                    : ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.all(8.0),
                        itemCount: processedMessageList.length,
                        itemBuilder: (context, index) {
                          final item = processedMessageList[index];
                          if (item is DateTime) { // It's a date divider
                            return _buildDateDivider(item);
                          } else if (item is ChatMessageModel) { // It's a message
                            return MessageBubble(
                              message: item,
                              isCurrentUser: item.senderId == _currentUserId,
                              // For group chats, senderDisplayName would be needed here
                            );
                          }
                          return SizedBox.shrink(); // Should not happen
                        },
                      ),
          ),
          // Copilot Suggestion Area
          if (_isGeneratingCopilotSuggestions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width:8), Text("AI thinking...")]),
            ),
          if (!_isGeneratingCopilotSuggestions && _copilotSuggestions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
                  child: Text(
                    "✨ AI Copilot suggestions (visible only to you):", // "该消息由 AI(Copilot) 起草..."
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                ..._copilotSuggestions.map((suggestion) => InkWell( // Making the whole suggestion tappable
                  onTap: () => _useCopilotSuggestion(suggestion),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(suggestion, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer))),
                        // Icon(Icons.send, size: 18, color: Theme.of(context).colorScheme.primary) // Optional "use" icon
                      ],
                    )
                  ),
                )).toList(),
                 SizedBox(height: 4), // Some spacing before input bar
              ],
            ),

          // ChatInputBar Integration
          ChatInputBar(
            controller: _messageController,
            onSendPressed: _isSendingMessage ? () {} : _sendMessage, // Disable button while sending
            onAttachPressed: () {
              // TODO: Implement attachment functionality
              print('Attach media pressed');
            },
          ),
        ],
      ),
    );
  }
}

```
