```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../models/chat_message_model.dart';
import '../models/user_model.dart'; // For member details
import '../services/chat_service.dart';
import '../services/ai/on_device_ai_service.dart';
// import '../services/chat_settings_service.dart'; // From IndividualChatScreen, can be reused
import '../widgets/message_bubble.dart';
// import '../widgets/chat_input_bar.dart'; // Will be integrated from Subtask 1.6
import './group_info_screen.dart'; // Placeholder for group settings/info

// Re-using ChatSettingsService from IndividualChatScreen's conceptual definition
// Should be in its own file: lib/services/chat_settings_service.dart
class ChatSettingsService {
  Future<Map<String, bool>> getAiSettings(String threadId, String userId) async {
    print('ChatSettingsService: Fetching AI settings for thread $threadId, user $userId');
    await Future.delayed(Duration(milliseconds: 150));
    return {'copilotEnabled': true, 'autopilotEnabled': false};
  }
  Future<bool> updateAiSettings(String threadId, String userId, {bool? copilotEnabled, bool? autopilotEnabled}) async {
    print('ChatSettingsService: Updating AI settings for thread $threadId, user $userId: Copilot=$copilotEnabled, Autopilot=$autopilotEnabled');
    await Future.delayed(Duration(milliseconds: 300));
    return true;
  }
}
// --- End Conceptual ChatSettingsService ---

// Re-using ChatInputBar from IndividualChatScreen's conceptual definition
// Should be in its own file: lib/widgets/chat_input_bar.dart
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachPressed;
  const ChatInputBar({Key? key, required this.controller, required this.onSendPressed, required this.onAttachPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: MediaQuery.of(context).padding.bottom + 8.0, top: 8.0),
      color: Theme.of(context).cardColor,
      child: Row(children: <Widget>[
        IconButton(icon: Icon(Icons.add_photo_alternate_outlined), onPressed: onAttachPressed, tooltip: "Attach media"),
        Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none), filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor, contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)), minLines: 1, maxLines: 5, textInputAction: TextInputAction.send, onSubmitted: (_) => onSendPressed())),
        SizedBox(width: 8.0),
        IconButton(icon: Icon(Icons.send_rounded), color: Theme.of(context).colorScheme.primary, onPressed: onSendPressed, tooltip: "Send message"),
      ]),
    );
  }
}
// --- End Conceptual ChatInputBar Widget ---

// Conceptual CopilotSuggestionBar (can be moved to its own file)
class CopilotSuggestionBar extends StatelessWidget {
  final String suggestionText;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const CopilotSuggestionBar({Key? key, required this.suggestionText, required this.onTap, required this.onDismiss}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.8), borderRadius: BorderRadius.circular(20.0)),
      child: Row(children: [
        Icon(Icons.auto_awesome_outlined, size: 20.0, color: Theme.of(context).colorScheme.onSecondaryContainer),
        SizedBox(width: 10.0),
        Expanded(child: GestureDetector(onTap: onTap, child: Text(suggestionText, style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onSecondaryContainer), maxLines: 2, overflow: TextOverflow.ellipsis))),
        SizedBox(width: 8.0),
        IconButton(icon: Icon(Icons.close, size: 20.0), color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.7), onPressed: onDismiss, padding: EdgeInsets.zero, constraints: BoxConstraints(), tooltip: "Dismiss suggestion"),
      ]),
    );
  }
}
// --- End Conceptual CopilotSuggestionBar ---

class GroupChatScreen extends StatefulWidget {
  final String threadId; // Group's threadId
  final String groupName;
  final String? groupAvatarUrl; // Optional
  final Color? groupAvatarColor; // Optional, for initial letter avatar

  const GroupChatScreen({
    Key? key,
    required this.threadId,
    required this.groupName,
    this.groupAvatarUrl,
    this.groupAvatarColor,
  }) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final OnDeviceAiService _aiService = OnDeviceAiService();
  final ChatSettingsService _chatSettingsService = ChatSettingsService();

  List<ChatMessageModel> _messages = [];
  Map<String, UserModel> _groupMembers = {}; // Store member details: userId -> UserModel
  bool _isLoadingMessages = true;
  bool _isLoadingMembers = true;
  bool _isSendingMessage = false;

  bool _copilotEnabled = true;
  bool _autopilotEnabled = false;
  List<String> _copilotSuggestions = [];
  bool _isGeneratingCopilotSuggestions = false;

  final String _currentUserId = 'currentUser123'; // From AuthService

  @override
  void initState() {
    super.initState();
    _loadInitialGroupData();
    _messageController.addListener(_onInputChanged);
  }

  Future<void> _loadInitialGroupData() async {
    setState(() {
      _isLoadingMessages = true;
      _isLoadingMembers = true;
    });
    try {
      // Fetch group members first to display names with messages
      // Conceptual: ChatService needs a method to get members of a group thread
      // final members = await _chatService.getGroupMembers(widget.threadId);
      // Simulate fetching members
      await Future.delayed(Duration(milliseconds: 200)); // Simulate delay
      final members = [ // Placeholder members
        UserModel(userId: 'userA', displayName: 'Alice', avatarUrl: null),
        UserModel(userId: 'userB', displayName: 'Bob', avatarUrl: null),
        UserModel(userId: _currentUserId, displayName: 'Me', avatarUrl: null), // Current user
      ];
      if (mounted) {
        setState(() {
          _groupMembers = {for (var member in members) member.userId: member};
          _isLoadingMembers = false;
        });
      }

      final messages = await _chatService.getMessages(widget.threadId);
      final aiSettings = await _chatSettingsService.getAiSettings(widget.threadId, _currentUserId);

      if (mounted) {
        setState(() {
          _messages = messages.reversed.toList();
          _copilotEnabled = aiSettings['copilotEnabled'] ?? true;
          _autopilotEnabled = aiSettings['autopilotEnabled'] ?? false;
          _isLoadingMessages = false;
        });
        if (_messages.isNotEmpty && _messages.first.senderId != _currentUserId) {
          _triggerCopilotSuggestion(_messages.first);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
          _isLoadingMembers = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load group chat: $e')));
    }
    // TODO: Setup stream listener for new messages from _chatService.getMessageStream()
  }

  void _onInputChanged() {
    if (_messageController.text.isNotEmpty && _copilotSuggestions.isNotEmpty) {
      setState(() { _copilotSuggestions = []; });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() { _isSendingMessage = true; _copilotSuggestions = []; });
    _messageController.clear();

    final newMessage = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      threadId: widget.threadId,
      text: text,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    try {
      await _chatService.sendMessage(widget.threadId, newMessage);
    } catch (e) { /* Handle error */ }
    finally { if (mounted) setState(() { _isSendingMessage = false; }); }
  }

  Future<void> _triggerCopilotSuggestion(ChatMessageModel incomingMessage) async {
    if (_copilotEnabled && incomingMessage.senderId != _currentUserId) {
      if (mounted) setState(() { _isGeneratingCopilotSuggestions = true; });
      try {
        String senderDisplayName = _groupMembers[incomingMessage.senderId]?.displayName ?? 'Someone';
        final suggestion = await _aiService.getCopilotSuggestion(incomingMessage.text, senderDisplayName);
        if (mounted && suggestion != null) {
          setState(() { _copilotSuggestions = [suggestion]; });
        }
      } catch (e) { /* Handle error */ }
      finally { if (mounted) setState(() { _isGeneratingCopilotSuggestions = false; }); }
    }
  }

  void _useCopilotSuggestion(String suggestion) { /* ... same as IndividualChatScreen ... */
    _messageController.text = suggestion;
    _messageController.selection = TextSelection.fromPosition(TextPosition(offset: _messageController.text.length));
    if(mounted) setState(() => _copilotSuggestions = [] );
  }

  void _showGroupChatSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupInfoScreen(
          threadId: widget.threadId,
          // groupName: widget.groupName // GroupInfoScreen would fetch details itself
        )
      )
    );
    // Or show a modal bottom sheet for quick AI toggles like in IndividualChatScreen
  }

  List<dynamic> _getMessagesWithDateDividers() { /* ... same as IndividualChatScreen ... */
    List<dynamic> items = [];
    DateTime? lastDate;
    for (var i = _messages.length - 1; i >= 0; i--) {
      final message = _messages[i];
      final messageDate = DateTime(message.timestamp.year, message.timestamp.month, message.timestamp.day);
      if (lastDate == null || !(lastDate.year == messageDate.year && lastDate.month == messageDate.month && lastDate.day == messageDate.day) ) {
        items.add(messageDate);
        lastDate = messageDate;
      }
      items.add(message);
    }
    return items.reversed.toList();
  }

  Widget _buildDateDivider(DateTime date) { /* ... same as IndividualChatScreen ... */
    return Center(child: Container(padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), margin: EdgeInsets.symmetric(vertical: 8.0), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12.0)), child: Text(DateFormat.yMMMd().format(date), style: TextStyle(fontSize: 12.0, color: Colors.black54, fontWeight: FontWeight.w600))));
  }


  @override
  void dispose() {
    _messageController.removeListener(_onInputChanged);
    _messageController.dispose();
    super.dispose();
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
              backgroundColor: widget.groupAvatarColor ?? Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: widget.groupAvatarUrl != null ? NetworkImage(widget.groupAvatarUrl!) : null,
              child: (widget.groupAvatarUrl == null && widget.groupName.isNotEmpty)
                  ? Text(widget.groupName[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer))
                  : (widget.groupAvatarUrl == null ? Icon(Icons.group_outlined, color: Theme.of(context).colorScheme.onPrimaryContainer) : null),
            ),
            SizedBox(width: 10),
            Expanded(child: Text(widget.groupName, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline), // Changed from more_vert for direct navigation
            onPressed: _showGroupChatSettings,
            tooltip: "Group Info & Settings",
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: (_isLoadingMessages || _isLoadingMembers)
                ? Center(child: CircularProgressIndicator())
                : processedMessageList.isEmpty
                    ? Center(child: Text('No messages yet. Start the conversation!'))
                    : ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.all(8.0),
                        itemCount: processedMessageList.length,
                        itemBuilder: (context, index) {
                          final item = processedMessageList[index];
                          if (item is DateTime) {
                            return _buildDateDivider(item);
                          } else if (item is ChatMessageModel) {
                            final senderName = (item.senderId != _currentUserId)
                                ? (_groupMembers[item.senderId]?.displayName ?? 'Unknown Member')
                                : null; // No name for current user's messages
                            return MessageBubble(
                              message: item,
                              isCurrentUser: item.senderId == _currentUserId,
                              // Pass senderDisplayName if MessageBubble is updated to use it
                              // senderDisplayName: senderName,
                              // For now, MessageBubble doesn't have this, so the UI would need adjustment
                              // or MessageBubble needs an update from subtask 4.3
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
          ),
          if (_isGeneratingCopilotSuggestions) /* ... Copilot loading UI ... */ Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width:8), Text("AI thinking...")])),
          if (!_isGeneratingCopilotSuggestions && _copilotSuggestions.isNotEmpty)
            CopilotSuggestionBar( // Using the conceptual widget
                suggestionText: _copilotSuggestions.first, // Assuming one suggestion for now
                onTap: () => _useCopilotSuggestion(_copilotSuggestions.first),
                onDismiss: () => setState(() => _copilotSuggestions = [])
            ),
          ChatInputBar( // Using the conceptual widget
            controller: _messageController,
            onSendPressed: _isSendingMessage ? () {} : _sendMessage,
            onAttachPressed: () { /* TODO: Implement attachment */ print('Attach media in group chat'); },
          ),
        ],
      ),
    );
  }
}
```
