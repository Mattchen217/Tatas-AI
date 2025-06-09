```dart
import 'dart:async';
import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';
import '../models/user_model.dart'; // For getGroupMembers

// Conceptual ChatSettingsService was defined in other files,
// for now, we can include its methods here or assume a separate service.

class ChatService {
  final Map<String, List<ChatMessageModel>> _chatMessagesStore = {
    'friend_user_id_1': [ /* ... existing simulated messages ... */ ],
    'group_thread_id_1': [
      ChatMessageModel(messageId: 'grp_msg1', senderId: 'userA', threadId: 'group_thread_id_1', text: 'Welcome to the group!', timestamp: DateTime.now().subtract(Duration(minutes: 10)), type: MessageType.text, senderDisplayName: "Alice"),
      ChatMessageModel(messageId: 'grp_msg2', senderId: 'userB', threadId: 'group_thread_id_1', text: 'Glad to be here!', timestamp: DateTime.now().subtract(Duration(minutes: 9)), type: MessageType.text, senderDisplayName: "Bob"),
    ],
  };

  // Simulated store for thread metadata (simplified)
  final Map<String, ChatThreadModel> _threadMetaStore = {
    'friend_user_id_1': ChatThreadModel(threadId: 'friend_user_id_1', participantIds: ['currentUser123', 'friend_user_id_1'], isGroup: false, lastActivity: DateTime.now().subtract(Duration(minutes:2)), lastMessage: ChatMessageModel(messageId: 'msg3', senderId: 'friend_user_id_1', threadId: 'friend_user_id_1', text: 'Doing well. Working on that Flutter project.', timestamp: DateTime.now().subtract(Duration(minutes: 2)), type: MessageType.text, senderDisplayName: "Friend 1")),
    'group_thread_id_1': ChatThreadModel(threadId: 'group_thread_id_1', participantIds: ['currentUser123', 'userA', 'userB'], groupName: 'Project Alpha', isGroup: true, lastActivity: DateTime.now().subtract(Duration(minutes:9)), lastMessage: ChatMessageModel(messageId: 'grp_msg2', senderId: 'userB', threadId: 'group_thread_id_1', text: 'Glad to be here!', timestamp: DateTime.now().subtract(Duration(minutes: 9)), type: MessageType.text, senderDisplayName: "Bob")),
  };

  // Simulated user store for getGroupMembers
  final Map<String, UserModel> _userStore = {
    'currentUser123': UserModel(userId: 'currentUser123', displayName: 'Me'),
    'friend_user_id_1': UserModel(userId: 'friend_user_id_1', displayName: 'Friend 1'),
    'userA': UserModel(userId: 'userA', displayName: 'Alice'),
    'userB': UserModel(userId: 'userB', displayName: 'Bob'),
  };


  final StreamController<ChatMessageModel> _messageStreamController = StreamController<ChatMessageModel>.broadcast();
  // Conceptual stream for thread updates (e.g., new last message, unread count)
  final StreamController<ChatThreadModel> _threadUpdateController = StreamController<ChatThreadModel>.broadcast();


  Future<List<ChatThreadModel>> getAllChatThreads(String userId) async {
    print('ChatService: Fetching all chat threads for user: $userId');
    await Future.delayed(Duration(milliseconds: 400));
    // Simulate filtering threads where user is a participant
    List<ChatThreadModel> threads = _threadMetaStore.values.where((thread) => thread.participantIds.contains(userId)).toList();
    // Simulate sorting: groups first, then by last activity
    threads.sort((a, b) {
      if (a.isGroup && !b.isGroup) return -1;
      if (!a.isGroup && b.isGroup) return 1;
      return (b.lastActivity ?? DateTime(1970)).compareTo(a.lastActivity ?? DateTime(1970));
    });
    return threads;
  }

  Future<List<ChatMessageModel>> getMessages(String threadId) async {
    print('ChatService: Fetching messages for thread: $threadId');
    await Future.delayed(Duration(milliseconds: 200));
    return _chatMessagesStore[threadId]?.map((msg) {
      // Attach sender display name if not already present (simulating join/lookup)
      if (msg.senderDisplayName == null) {
        final sender = _userStore[msg.senderId];
        return ChatMessageModel(
          messageId: msg.messageId, threadId: msg.threadId, senderId: msg.senderId, text: msg.text,
          timestamp: msg.timestamp, type: msg.type, mediaUrl: msg.mediaUrl,
          structuredContent: msg.structuredContent, isRead: msg.isRead,
          senderDisplayName: sender?.displayName ?? 'Unknown', // Add display name
          senderAvatarUrl: sender?.avatarUrl
        );
      }
      return msg;
    }).toList() ?? [];
  }

  Future<void> sendMessage(String threadId, ChatMessageModel message) async {
    print('ChatService: Sending message to thread: $threadId, Text: ${message.text ?? "Structured Content"}');
    await Future.delayed(Duration(milliseconds: 100));

    if (!_chatMessagesStore.containsKey(threadId)) {
      _chatMessagesStore[threadId] = [];
    }
    // Attach sender display name if not already present (simulating join/lookup for storage/broadcast)
    final sender = _userStore[message.senderId];
    final messageToSend = ChatMessageModel(
        messageId: message.messageId, threadId: message.threadId, senderId: message.senderId, text: message.text,
        timestamp: message.timestamp, type: message.type, mediaUrl: message.mediaUrl,
        structuredContent: message.structuredContent, isRead: true, // Assume sent message is read by sender
        senderDisplayName: message.senderDisplayName ?? sender?.displayName ?? 'Unknown',
        senderAvatarUrl: message.senderAvatarUrl ?? sender?.avatarUrl
      );

    _chatMessagesStore[threadId]!.add(messageToSend);
    _messageStreamController.add(messageToSend); // Broadcast to active listeners

    // Update thread metadata
    if (_threadMetaStore.containsKey(threadId)) {
      _threadMetaStore[threadId] = _threadMetaStore[threadId]!.copyWith( // Assuming ChatThreadModel has copyWith
        lastMessage: messageToSend,
        lastActivity: messageToSend.timestamp,
        // unreadCount might be updated differently, e.g. server logic based on recipients
      );
      _threadUpdateController.add(_threadMetaStore[threadId]!);
    }
    print('ChatService: Message sent and added to stream.');
  }

  Stream<ChatMessageModel> getNewMessageStream(String threadId) {
    return _messageStreamController.stream.where((message) => message.threadId == threadId);
  }

  Stream<ChatThreadModel> getUpdatedThreadStream(String userId) {
    // Filters threads relevant to the user. More complex filtering might be needed.
    return _threadUpdateController.stream.where((thread) => thread.participantIds.contains(userId));
  }

  Future<ChatThreadModel?> createGroupChat(String groupName, List<String> memberIds, {String? groupAvatarUrl, String? currentUserId}) async {
    print('ChatService: Creating group "$groupName" with members: ${memberIds.join(', ')}');
    await Future.delayed(Duration(seconds: 1));
    String newThreadId = "group_${DateTime.now().millisecondsSinceEpoch}";

    final initialMessageText = "${_userStore[currentUserId]?.displayName ?? 'Someone'} created the group '$groupName'.";
    final initialSystemMessage = ChatMessageModel(
      messageId: 'sys_${DateTime.now().millisecondsSinceEpoch}',
      threadId: newThreadId,
      senderId: 'system', // Special senderId for system messages
      senderDisplayName: 'System',
      text: initialMessageText,
      timestamp: DateTime.now(),
      type: MessageType.system,
    );

    final newGroup = ChatThreadModel(
      threadId: newThreadId,
      participantIds: memberIds,
      groupName: groupName,
      groupAvatarUrl: groupAvatarUrl,
      isGroup: true,
      lastMessage: initialSystemMessage,
      lastActivity: initialSystemMessage.timestamp,
    );
    _threadMetaStore[newThreadId] = newGroup;
    _chatMessagesStore[newThreadId] = [initialSystemMessage]; // Add initial system message

    _threadUpdateController.add(newGroup); // Notify about new thread
    _messageStreamController.add(initialSystemMessage); // Send initial system message

    print('ChatService: Group created with ID: $newThreadId');
    return newGroup;
  }

  Future<List<UserModel>> getGroupMembers(String threadId) async {
    print('ChatService: Fetching members for group: $threadId');
    await Future.delayed(Duration(milliseconds: 100));
    final thread = _threadMetaStore[threadId];
    if (thread != null && thread.isGroup) {
      return thread.participantIds.map((id) => _userStore[id] ?? UserModel(userId: id, displayName: 'Unknown Member ($id)')).toList();
    }
    return [];
  }

  // --- AI Settings Methods (Conceptual) ---
  // In a real app, these would interact with a backend that stores these settings per user per thread.
  // For simulation, we can store them in a local map in the service if needed, or assume ChatSettingsService.
  Map<String, Map<String, Map<String, bool>>> _threadAiSettings = {}; // threadId -> userId -> settings

  Future<Map<String, bool>> getAiSettings(String threadId, String userId) async {
    print('ChatService: Getting AI settings for thread $threadId, user $userId');
    await Future.delayed(Duration(milliseconds: 50));
    return _threadAiSettings[threadId]?[userId] ?? {'copilotEnabled': true, 'autopilotEnabled': false}; // Default
  }

  Future<void> updateAiSettings(String threadId, String userId, {bool? copilotEnabled, bool? autopilotEnabled}) async {
    print('ChatService: Updating AI settings for thread $threadId, user $userId: Copilot=$copilotEnabled, Autopilot=$autopilotEnabled');
    await Future.delayed(Duration(milliseconds: 100));
    if (!_threadAiSettings.containsKey(threadId)) {
      _threadAiSettings[threadId] = {};
    }
    if (!_threadAiSettings[threadId]!.containsKey(userId)) {
      _threadAiSettings[threadId]![userId] = {'copilotEnabled': true, 'autopilotEnabled': false}; // Initialize with defaults
    }
    if (copilotEnabled != null) {
      _threadAiSettings[threadId]![userId]!['copilotEnabled'] = copilotEnabled;
    }
    if (autopilotEnabled != null) {
      _threadAiSettings[threadId]![userId]!['autopilotEnabled'] = autopilotEnabled;
    }
    // Conceptual: Notify relevant parts of the app if settings change, e.g. via a stream or callback.
  }


  void disposeStreamControllers() {
    _messageStreamController.close();
    _threadUpdateController.close();
  }
}

// Extension for ChatThreadModel to add copyWith (if not part of the original model)
extension ChatThreadModelCopyWith on ChatThreadModel {
  ChatThreadModel copyWith({
    ChatMessageModel? lastMessage,
    DateTime? lastActivity,
    int? unreadCount,
    List<String>? participantIds,
    String? groupName,
    String? groupAvatarUrl,
    bool? isGroup,
  }) {
    return ChatThreadModel(
      threadId: this.threadId,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      groupName: groupName ?? this.groupName,
      groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
      isGroup: isGroup ?? this.isGroup,
      clientSideAvatarColorHex: this.clientSideAvatarColorHex,
    );
  }
}
```
